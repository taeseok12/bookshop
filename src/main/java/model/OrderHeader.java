package model;

import lombok.Data;



//model/OrderHeader.java
@Data
public class OrderHeader {
 private Long orderId;
 private Long userId;
 private java.util.Date orderDate;   // ← java.util.Date 권장
 private String status;
 private Integer totalAmount;

 private String address;
 private String postcode;
 private String trackingNo;

 // ▼ XML과 맞추기
 private String courier;
 private java.util.Date shippedAt;
 private java.util.Date deliveredAt;
 private java.util.Date cancelledAt;
}
