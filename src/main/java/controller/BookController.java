package controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import dto.PageCriteria;
import dto.PageResult;
import model.Book;
import service.BookService;

@Controller
public class BookController {

    @Autowired
    private BookService bookservice;

    /**
     * 목록 페이지
     * - keyword가 있으면 검색 + 페이징
     * - 없으면 전체 목록 페이징
     */
    @GetMapping("bookstore/books")
    public String list(@RequestParam(required = false) Integer page,
                       @RequestParam(required = false) Integer size,
                       @RequestParam(required = false) String keyword,
                       @RequestParam(required = false) String view, // 사용자가 명시한 view
                       Model model) {

        PageCriteria criteria = new PageCriteria(page, size);
        boolean hasKeyword = (keyword != null && !keyword.isBlank());

        // ✅ view 결정 규칙
        String effectiveView;
        if (hasKeyword) {
            // 검색 중이면 사용자가 view를 명시하지 않은 경우 list로
            effectiveView = (view == null || view.isBlank()) ? "list" : view;
        } else {
            // 검색이 아니면 항상 grid 강제
            effectiveView = "grid";
        }

        PageResult<Book> result = hasKeyword
                ? bookservice.searchByKeyword(keyword.trim(), criteria)
                : bookservice.getBooks(criteria);

        model.addAttribute("books", result.getContent());
        model.addAttribute("page", result.getPage());
        model.addAttribute("size", result.getSize());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("hasPrev", result.isHasPrev());
        model.addAttribute("hasNext", result.isHasNext());
        model.addAttribute("totalCount", result.getTotal());
        model.addAttribute("result", result);
        model.addAttribute("keyword", hasKeyword ? keyword.trim() : null);
        model.addAttribute("view", effectiveView);   // ✅ 결정된 뷰를 모델로 전달
        return "bookstore/book";
    }

    @GetMapping("/api/books/suggest")
    @ResponseBody
    public List<Book> suggest(@RequestParam("keyword") String keyword,
                              @RequestParam(defaultValue = "5") int limit) {
        return bookservice.suggestBooks(keyword, limit);
    }


    @GetMapping("/bookstore")
    public String redirectToBooks() {
        return "redirect:/bookstore/books";
    }

    /** 상세보기 페이지 */
    @GetMapping("/bookstore/book/{bookId}")
    public String bookDetail(@PathVariable("bookId") Long bookId, Model model) {
        Book book = bookservice.getOne(bookId);
        if (book == null) {
            return "error/404";
        }
        model.addAttribute("book", book);
        return "bookstore/bookDetail";
    }

    @GetMapping("/bookstore/cart")
    public String cartPage() {
        return "bookstore/cart";
    }
}
