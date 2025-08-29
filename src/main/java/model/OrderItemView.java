package model;

import lombok.Data;

@Data
public class OrderItemView {
    private Long orderItemId;  // ★ 추가 (oi.order_item_id)
    private Long orderId;      // oi.order_id
    private Long bookId;       // oi.book_id
    private String bookTitle;  // b.title AS book_title
    private String author;     // b.author
    private String coverImage; // b.cover_image
    private Long unitPrice;    // oi.unit_price
    private Integer quantity;  // oi.quantity
    // 추가
    private String address;
    private String postcode;
    // (옵션) 쿼리에서 line_total을 안 내려줄 때 화면에서 쓰는 편의 게터
    public Long getLineTotal() {
        if (unitPrice == null || quantity == null) return 0L;
        return unitPrice * quantity;
    }
}