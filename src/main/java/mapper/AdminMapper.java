package mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import model.DashboardStats.TopBook;

public interface AdminMapper {

    // 대시보드
    int selectUserCount();
    int selectOrderCount();
    Long selectTotalSales(); // null 방지 위해 서비스에서 0 처리
    List<TopBook> selectBestsellersTop5();

    // 사용자
    List<Map<String, Object>> findUsers(
            @Param("keyword") String keyword,
            @Param("role") String role
    );
    int updateUserRole(
            @Param("userId") Long userId,
            @Param("role") String role
    );

    // 도서
    List<Map<String, Object>> findBooks(
            @Param("keyword") String keyword
    );
    int insertBook(Map<String, Object> book);
    int updateBook(Map<String, Object> book);
    int deleteBook(@Param("bookId") Long bookId);

    // 주문
    List<Map<String, Object>> findOrders(
            @Param("status") String status
    );
    int updateOrderStatus(
            @Param("orderId") Long orderId,
            @Param("status") String status
    );
    List<Map<String, Object>> findOrderItems(@Param("orderId") Long orderId);
    
    int updateUserActive(@Param("userId") Long userId,
            @Param("active") String active);
    
 // mapper/AdminMapper.java (추가)
    Map<String,Object> selectBookById(@Param("bookId") Long bookId);
     

    int updateOrderCourier(@Param("orderId") Long orderId,
                           @Param("courier") String courier,
                           @Param("trackingNo") String trackingNo);
    
    List<Map<String,Object>> selectDailySalesLast30();
    List<Map<String,Object>> selectMonthlySalesLast12();
    List<Map<String,Object>> selectOrderStatusCounts();
    Map<String,Object>       selectInventoryBuckets();

}
