package mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import model.OrderItemView;

@Mapper
public interface OrderItemMapper {

    /** 주문 상세 화면: 특정 주문의 아이템 목록 (본인주문 권한 체크용 userId 포함) */
    List<OrderItemView> selectOrderItems(@Param("orderId") Long orderId,
                                         @Param("userId")  Long userId);

    /** 여러 주문의 아이템을 한 번에 조회(목록 카드 요약 등에 사용) */
    List<OrderItemView> selectItemsByOrderIds(@Param("orderIds") List<Long> orderIds,
                                              @Param("userId")   Long userId);

    /** (옵션) 주문의 상품 소계(단가×수량 합) */
    Long calcOrderSubtotal(@Param("orderId") Long orderId);
    Map<String, Object> selectAddress(@Param("orderId") Long orderId);
}