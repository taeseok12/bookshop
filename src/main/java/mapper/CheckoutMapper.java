package mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

public interface CheckoutMapper {

    /** 주문 헤더 저장 */
    void insertOrder(Map<String, Object> order);

    /** 직전 생성된 주문 ID 조회 */
    Long selectCurrOrderId();

    /** 주문 항목 저장 */
    void insertOrderItem(Map<String, Object> item);

    /** 완료 화면: 주문 헤더 조회 */
    Map<String, Object> findOrderById(Long orderId);

    /** 완료 화면: 주문 항목 + 책 제목 조회 */
    List<Map<String, Object>> findOrderItemsByOrderId(Long orderId);
    // 추가 -----------------------------------
    /** 결제창 표시용: 본인 주문인지 확인하고 헤더 조회 */
    Map<String, Object> findOrderForUser(@Param("orderId") Long orderId,
                                         @Param("userId") Long userId);

    /** 결제 완료 처리: 상태/결제수단/시간 업데이트 */
    int updateOrderStatus(@Param("orderId") Long orderId,
                          @Param("status") String status,
                          @Param("method") String method);
    
}

