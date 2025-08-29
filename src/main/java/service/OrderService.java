package service;

import dto.PageCriteria;
import dto.PageResult;
import lombok.RequiredArgsConstructor;
import mapper.BookMapper;
import mapper.OrderItemMapper;
import mapper.OrderMapper;
import model.Book;
import model.OrderHeader;
import model.OrderItemView;
import model.OrderSummary;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final BookMapper bookMapper; // ✅ 총액/단가 계산에 필요

    public PageResult<OrderSummary> getMyOrders(Long userId, PageCriteria criteria) {
        int offset = criteria.offset();
        int page   = criteria.getPage();
        int size   = criteria.getSize();

        List<OrderSummary> content = orderMapper.selectOrdersByUser(userId, offset, size);
        int total = orderMapper.countOrdersByUser(userId);

        return new PageResult<>(content, page, size, total);
    }

    public OrderHeader getOrderHeader(Long orderId, Long userId) {
        return orderMapper.selectOrderHeader(orderId, userId);
    }

    public List<OrderItemView> getOrderItems(Long orderId, Long userId) {
        return orderItemMapper.selectOrderItems(orderId, userId);
    }

    // 기존: Map<Integer, List<OrderItemView>>
    public Map<Long, List<OrderItemView>> getItemsForOrderIds(List<Long> orderIds, Long userId) {
        List<OrderItemView> items = orderItemMapper.selectItemsByOrderIds(orderIds, userId);
        return items.stream().collect(Collectors.groupingBy(OrderItemView::getOrderId));
    }

    /** (옵션) 상세화면 금액 박스용 소계 */
    public Long getOrderSubtotal(Long orderId) {
        return orderItemMapper.calcOrderSubtotal(orderId);
    }

    /** 상세 보기에서 헤더+아이템을 한 번에 세팅하고 싶을 때 */
    public Map<String, Object> getOrderDetail(Long orderId, Long userId) {
        Map<String, Object> m = new HashMap<>();
        m.put("header", orderMapper.selectOrderHeader(orderId, userId)); // null일 수 있음
        m.put("items", orderItemMapper.selectOrderItems(orderId, userId));
        return m;
    }

    // ---------------------------------------------
    // 🔧 교체한 주문 생성 메서드(정식)
    // ---------------------------------------------
    /**
     * 주문 생성 (장바구니/바로구매 공용)
     * @param userId  주문자
     * @param address 배송지
     * @param postcode 우편번호
     * @param wanted  주문할 도서와 수량 (key: bookId, value: qty)
     * @return 생성된 orderId
     */
    @Transactional
    public Long placeOrder(Long userId, String address, String postcode,
                           Map<Long, Integer> wanted) {

        if (wanted == null || wanted.isEmpty())
            throw new IllegalArgumentException("주문 항목이 비어 있습니다.");

        // 1) 단가/재고 확인 & 총액 계산
        List<Long> ids = new ArrayList<>(wanted.keySet());
        List<Book> books = bookMapper.findByIdList(ids);
        Map<Long, Book> bookMap = books.stream()
                .collect(Collectors.toMap(Book::getBookId, b -> b));

        BigDecimal total = BigDecimal.ZERO;
        for (Map.Entry<Long, Integer> e : wanted.entrySet()) {
            Long bookId = e.getKey();
            int qty = Math.max(1, e.getValue());
            Book b = bookMap.get(bookId);
            if (b == null) throw new IllegalArgumentException("존재하지 않는 도서가 포함되었습니다. id=" + bookId);
            if (b.getStock() == null || b.getStock() < qty)
                throw new IllegalStateException("재고가 부족한 도서가 있습니다. id=" + bookId);

            BigDecimal price = BigDecimal.valueOf(b.getPrice());
            total = total.add(price.multiply(BigDecimal.valueOf(qty)));
        }

        // 2) 주문 헤더 저장 (PENDING)
        Map<String, Object> order = new HashMap<>();
        order.put("userId", userId);
        order.put("status", "PENDING");
        order.put("totalAmount", total);
        order.put("address", address);
        order.put("postcode", postcode);
        orderMapper.insertOrder(order);

        Long orderId = orderMapper.selectCurrOrderId(); // ✅ 실제 시그니처
        if (orderId == null) throw new IllegalStateException("주문 ID 생성 실패");

        // 3) 주문 항목 저장 (스냅샷: unit_price)
        for (Map.Entry<Long, Integer> e : wanted.entrySet()) {
            Long bookId = e.getKey();
            int qty = Math.max(1, e.getValue());
            BigDecimal unitPrice = BigDecimal.valueOf(bookMap.get(bookId).getPrice());
            orderMapper.insertOrderItem(orderId, bookId, qty, unitPrice); // ✅ 시그니처에 맞춤
        }

        return orderId;
    }
}
