package model;

import java.util.List;

public class DashboardStats {
    private int userCount;        // 총 회원 수
    private int orderCount;       // 총 주문 건수
    private long totalSales;      // 총 매출
    private List<TopBook> topBooks; // 베스트셀러 Top 5

    public static class TopBook {
        private Long bookId;
        private String title;
        private String author;
        private Long totalQty;

        public Long getBookId() { return bookId; }
        public void setBookId(Long bookId) { this.bookId = bookId; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getAuthor() { return author; }
        public void setAuthor(String author) { this.author = author; }
        public Long getTotalQty() { return totalQty; }
        public void setTotalQty(Long totalQty) { this.totalQty = totalQty; }
    }

    public int getUserCount() { return userCount; }
    public void setUserCount(int userCount) { this.userCount = userCount; }
    public int getOrderCount() { return orderCount; }
    public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
    public long getTotalSales() { return totalSales; }
    public void setTotalSales(long totalSales) { this.totalSales = totalSales; }
    public List<TopBook> getTopBooks() { return topBooks; }
    public void setTopBooks(List<TopBook> topBooks) { this.topBooks = topBooks; }
}
