package service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import mapper.AdminMapper;
import model.DashboardStats;
import model.DashboardStats.TopBook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminService {

    @Autowired
    private AdminMapper adminMapper;

    // 대시보드
    public DashboardStats getDashboardStats() {
        DashboardStats stats = new DashboardStats();
        stats.setUserCount(adminMapper.selectUserCount());
        stats.setOrderCount(adminMapper.selectOrderCount());
        Long sales = adminMapper.selectTotalSales();
        stats.setTotalSales(sales == null ? 0L : sales);
        List<TopBook> top = adminMapper.selectBestsellersTop5();
        stats.setTopBooks(top);
        return stats;
    }

    // 사용자
    public List<Map<String, Object>> findUsers(String keyword, String role) {
        return adminMapper.findUsers(sanitize(keyword), sanitize(role));
    }

    @Transactional
    public void changeUserRole(Long userId, String role) {
        if (userId == null) throw new IllegalArgumentException("userId is required");
        if (role == null) throw new IllegalArgumentException("role is required");
        adminMapper.updateUserRole(userId, role);
    }

    public void changeUserActive(Long userId, String active) {
        if (userId == null) throw new IllegalArgumentException("userId is required");
        if (!"Y".equals(active) && !"N".equals(active)) throw new IllegalArgumentException("active must be Y or N");
        adminMapper.updateUserActive(userId, active);
    }

    // 도서
    public List<Map<String, Object>> findBooks(String keyword) {
        return adminMapper.findBooks(sanitize(keyword));
    }

    @Transactional
    public void createBook(Map<String, Object> book) {
        validateBookForInsert(book);
        adminMapper.insertBook(new HashMap<>(book));
    }

    @Transactional
    public void updateBook(Map<String, Object> book) {
        if (book == null || book.get("book_id") == null) {
            throw new IllegalArgumentException("book_id is required for update");
        }
        adminMapper.updateBook(new HashMap<>(book));
    }

    @Transactional
    public void deleteBook(Long bookId) {
        if (bookId == null) throw new IllegalArgumentException("bookId is required");
        adminMapper.deleteBook(bookId);
    }

    public Map<String, Object> getBook(Long bookId) {
        if (bookId == null) throw new IllegalArgumentException("bookId is required");
        return adminMapper.selectBookById(bookId);
    }

    // 주문
    public List<Map<String, Object>> findOrders(String status) {
        return adminMapper.findOrders(sanitize(status));
    }

    /** ✅ 컨트롤러와 시그니처 일치: int 반환 */
    @Transactional
    public int updateOrderStatus(Long orderId, String status) {
        if (orderId == null) throw new IllegalArgumentException("orderId is required");
        if (status == null) throw new IllegalArgumentException("status is required");
        return adminMapper.updateOrderStatus(orderId, status);
    }

    public List<Map<String, Object>> findOrderItems(Long orderId) {
        if (orderId == null) throw new IllegalArgumentException("orderId is required");
        return adminMapper.findOrderItems(orderId);
    }

    /** 송장/택배사 저장 (반환값 그대로 컨트롤러로) */
    @Transactional
    public int updateOrderCourier(Long orderId, String courier, String trackingNo) {
        return adminMapper.updateOrderCourier(orderId, courier, trackingNo);
    }

    // helpers
    private String sanitize(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }

    private void validateBookForInsert(Map<String, Object> book) {
        if (book == null) throw new IllegalArgumentException("book data is required");
        if (!book.containsKey("title") || !book.containsKey("author")
                || !book.containsKey("price") || !book.containsKey("stock")) {
            throw new IllegalArgumentException("title, author, price, stock are required");
        }
    }
    
 // 대시보드 차트용
    public List<Map<String, Object>> getDailySalesLast30() {
        return adminMapper.selectDailySalesLast30();
    }

    public List<Map<String, Object>> getMonthlySalesLast12() {
        return adminMapper.selectMonthlySalesLast12();
    }

    public List<Map<String, Object>> getOrderStatusCounts() {
        return adminMapper.selectOrderStatusCounts();
    }

    public Map<String, Object> getInventoryBuckets() {
        return adminMapper.selectInventoryBuckets();
    }

}
