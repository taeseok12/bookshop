package service;

import java.util.Collections;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dto.PageCriteria;
import dto.PageResult;
import mapper.BookMapper;
import model.Book;

@Service
public class BookService {

    @Autowired
    private BookMapper mapper;

    // ===== 페이징 정책 =====
    private static final int DEFAULT_PAGE_SIZE = 20;  // UX 기본
    private static final int MIN_PAGE_SIZE     = 10;  // 최솟값(교보 사례 참고)
    private static final int MAX_PAGE_SIZE     = 50;  // 최댓값(교보 사례 참고)

    // ===== 공통 헬퍼 =====
    private int clampSize(Integer size) {
        if (size == null) return DEFAULT_PAGE_SIZE;
        return Math.max(MIN_PAGE_SIZE, Math.min(size, MAX_PAGE_SIZE));
    }

    private int clampPage(Integer page) {
        return (page == null || page < 1) ? 1 : page;
    }

    /** 총건수와 요청 page/size를 받아 안전한 페이지(1~totalPages)를 계산 */
    private int safePage(int requested, int size, int total) {
        int totalPages = (int) Math.ceil(total / (double) size);
        if (totalPages <= 0) return 1;                 // 데이터 0건
        if (requested < 1)  return 1;                 // 0/음수 방어
        return Math.min(requested, totalPages);        // 초과 시 마지막 페이지
    }

    /** 1페이지 기준 0 offset */
    private int offset(int page, int size) {
        int p = Math.max(1, page);
        return (p - 1) * size;
    }

    // ===== 조회 메서드 =====

    @Transactional(readOnly = true)
    public List<Book> getAll() {
        return mapper.findAllBooks();
    }

    @Transactional(readOnly = true)
    public Book getOne(Long id) {
        return mapper.findBookById(id);
    }

    @Transactional(readOnly = true)
    public List<Book> findByIdList(List<Long> ids) {
        if (ids == null || ids.isEmpty()) return Collections.emptyList();
        return mapper.findByIds(ids);
    }

    /** 전체 목록 페이징 */
    @Transactional(readOnly = true)
    public PageResult<Book> getBooks(PageCriteria criteria) {
        final int size    = clampSize(criteria != null ? criteria.getSize() : null);
        final int reqPage = clampPage(criteria != null ? criteria.getPage() : null);

        final int total       = mapper.countBooks();
        final int currentPage = safePage(reqPage, size, total);
        final int off         = offset(currentPage, size);

        final List<Book> content = mapper.findBooksPage(off, size);
        return new PageResult<>(content, currentPage, size, total);
    }

    /** 키워드 검색 (제목/저자 LIKE) + 페이징 */
    @Transactional(readOnly = true)
    public PageResult<Book> searchByKeyword(String keyword, PageCriteria criteria) {
        final int size    = clampSize(criteria != null ? criteria.getSize() : null);
        final int reqPage = clampPage(criteria != null ? criteria.getPage() : null);

        if (keyword == null || keyword.isBlank()) {
            return new PageResult<>(List.of(), 1, size, 0);
        }

        int total = mapper.countByKeyword(keyword);
        int currentPage = safePage(reqPage, size, total);
        int off = offset(currentPage, size);

        List<Book> content = mapper.searchBooksByKeyword(keyword, off, size);

        // 0건이면 공백 제거 버전 재시도(필요 시)
        if (total == 0) {
            String processed = keyword.replaceAll("\\s+", "");
            total = mapper.countByKeyword(processed);
            currentPage = safePage(reqPage, size, total);
            off = offset(currentPage, size);
            content = mapper.searchBooksByKeyword(processed, off, size);
        }

        return new PageResult<>(content, currentPage, size, total);
    }

    /** 카테고리별 조회 + 페이징 */
    @Transactional(readOnly = true)
    public PageResult<Book> getByCategory(String category, PageCriteria criteria) {
        final int size    = clampSize(criteria != null ? criteria.getSize() : null);
        final int reqPage = clampPage(criteria != null ? criteria.getPage() : null);

        final int total       = mapper.countByCategory(category);
        final int currentPage = safePage(reqPage, size, total);
        final int off         = offset(currentPage, size);

        final List<Book> content = mapper.findBooksByCategory(category, off, size);
        return new PageResult<>(content, currentPage, size, total);
    }

    /** 가격 범위 조회 + 페이징 */
    @Transactional(readOnly = true)
    public PageResult<Book> getByPriceRange(int min, int max, PageCriteria criteria) {
        final int size    = clampSize(criteria != null ? criteria.getSize() : null);
        final int reqPage = clampPage(criteria != null ? criteria.getPage() : null);

        final int total       = mapper.countByPriceRange(min, max);
        final int currentPage = safePage(reqPage, size, total);
        final int off         = offset(currentPage, size);

        final List<Book> content = mapper.searchBooksByPriceRange(min, max, off, size);
        return new PageResult<>(content, currentPage, size, total);
    }

    /** 자동완성/서제스트 (가벼운 결과: id, title, author 정도를 XML에서 선별 권장) */
    @Transactional(readOnly = true)
    public List<Book> suggestBooks(String keyword, int limit) {
        if (keyword == null || keyword.isBlank()) return List.of();
        int safeLimit = (limit <= 0 || limit > 20) ? 8 : limit; // 안전 상한
        return mapper.suggestBooks(keyword, safeLimit);
    }

    // ===== 쓰기(재고 차감) =====

    @Transactional
    public void decreaseStock(Long bookId, int quantity) {
        int updated = mapper.decreaseStock(bookId, quantity);
        if (updated != 1) {
            throw new IllegalStateException("재고 차감 실패 또는 대상 없음");
        }
    }
}
