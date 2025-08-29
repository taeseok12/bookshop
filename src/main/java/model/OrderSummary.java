package model;

import lombok.Data;

import java.sql.Date;

@Data
public class OrderSummary {
    private Long orderId;
    private Long userId;
    private Date orderDate;
    private String status;
    private Integer totalAmount;
    private String receiverName;
    private String firstBookTitle;
    private String firstBookCover;
    private Integer totalBookCount;
}