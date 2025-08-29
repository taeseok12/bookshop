package mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import model.OrderHeader;
import model.OrderSummary;

public interface OrderMapper {

    // ===== 조회(마이페이지) =====
    List<OrderSummary> selectOrdersByUser(@Param("userId") Long userId,
                                          @Param("offset") int offset,
                                          @Param("limit") int limit);

    int countOrdersByUser(@Param("userId") Long userId);

    OrderHeader selectOrderHeader(@Param("orderId") Long orderId,
                                  @Param("userId") Long userId);

    // ===== 생성(체크아웃) / 항목 =====
    int insertOrder(Map<String, Object> orderParams);   // userId, totalAmount, address, postcode, (opt)status,courier,trackingNo
    Long selectCurrOrderId();                           // 같은 세션에서 CURRVAL
    int insertOrderItem(@Param("orderId") Long orderId,
                        @Param("bookId") Long bookId,
                        @Param("quantity") int quantity,
                        @Param("unitPrice") Number unitPrice);

    // ===== 상태/송장 업데이트 =====
    int updateOrderStatus(@Param("orderId") Long orderId,
                          @Param("status") String status);

    int updateOrderCourier(@Param("orderId") Long orderId,
                           @Param("courier") String courier,
                           @Param("trackingNo") String trackingNo);
    
 // OrderMapper.java 에 아래 메서드가 선언되어 있어야 합니다.
    Map<String,Object> findOrderForUser(@Param("orderId") Long orderId,
                                        @Param("userId") Long userId);

    List<Map<String,Object>> findOrderItemsByOrderId(@Param("orderId") Long orderId);

}
