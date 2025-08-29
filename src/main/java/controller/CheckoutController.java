package controller;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.security.Principal;
import java.util.*;
import java.util.stream.Collectors;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import model.Book;
import mapper.BookMapper;
import mapper.OrderMapper;
import mapper.UserMapper;

@Controller
@RequestMapping("/bookstore")
public class CheckoutController {

  private final UserMapper userMapper;
  private final BookMapper bookMapper;
  private final OrderMapper orderMapper;     // ✅ 통합: 주문 관련 Mapper
  private final ObjectMapper om = new ObjectMapper();

  public CheckoutController(UserMapper userMapper, BookMapper bookMapper, OrderMapper orderMapper) {
    this.userMapper = userMapper;
    this.bookMapper = bookMapper;
    this.orderMapper = orderMapper;
  }

  /** 1) 주소 입력 후 '주문만 생성' (장바구니 or 바로구매 모두 지원) */
  @PostMapping("/checkout/confirm")
  @Transactional
  public String confirm(Principal principal,
                        @RequestParam(value = "address",  required = false) String address,
                        @RequestParam(value = "postcode", required = false) String postcode,
                        @RequestParam(value = "buyNowBookId", required = false) Long buyNowBookId, // 바로구매: 도서ID
                        @RequestParam(value = "buyNowQty",    required = false) Integer buyNowQty,  // 바로구매: 수량
                        HttpServletRequest req, HttpServletResponse res,
                        RedirectAttributes ra) throws UnsupportedEncodingException {

    // 로그인 검증
    if (principal == null || principal.getName() == null) {
      ra.addFlashAttribute("error", "다시 로그인해주세요");
      return "redirect:/loginForm";
    }
    String loginId = principal.getName();
    Long userId = userMapper.findUserIdByLoginId(loginId);
    if (userId == null) {
      ra.addFlashAttribute("error", "다시 로그인해주세요");
      return "redirect:/loginForm";
    }

    // 주소 검증
    if (address == null || address.isBlank()) {
      ra.addFlashAttribute("error", "주소를 입력하세요");
      return "redirect:/bookstore/checkoutForm";
    }
    if (postcode == null || postcode.isBlank()) {
      ra.addFlashAttribute("error", "우편번호를 입력하세요");
      return "redirect:/bookstore/checkoutForm";
    }

    // ✅ 주문 대상(wanted) 구성: 바로구매 파라미터가 있으면 그걸 우선 사용
    Map<Long, Integer> wanted;
    if (buyNowBookId != null) {
      int q = (buyNowQty == null ? 1 : Math.max(1, Math.min(99, buyNowQty)));
      wanted = new LinkedHashMap<>();
      wanted.put(buyNowBookId, q);
    } else {
      wanted = readCartCookieToWantedMap(req);
    }

    if (wanted.isEmpty()) {
      ra.addFlashAttribute("error", "장바구니가 비어있습니다");
      return "redirect:/bookstore/cart";
    }

    // 도서 조회
    List<Book> rows = bookMapper.findByIdList(new ArrayList<>(wanted.keySet()));
    Map<Long, Book> bookMap = rows.stream().collect(Collectors.toMap(Book::getBookId, b -> b));

    // 총액/유효성
    BigDecimal total = BigDecimal.ZERO;
    for (Map.Entry<Long, Integer> e : wanted.entrySet()) {
      Long bookId = e.getKey(); int qty = e.getValue();
      Book b = bookMap.get(bookId);
      if (b == null) { ra.addFlashAttribute("error", "존재하지 않는 도서가 포함되었습니다"); return "redirect:/bookstore/cart"; }
      if (qty < 1)   { ra.addFlashAttribute("error", "잘못된 수량이 포함되었습니다");     return "redirect:/bookstore/cart"; }
      if (b.getStock() == null || b.getStock() < qty) {
        ra.addFlashAttribute("error", "재고가 부족한 도서가 있습니다"); return "redirect:/bookstore/cart";
      }
      total = total.add(BigDecimal.valueOf(b.getPrice()).multiply(BigDecimal.valueOf(qty)));
    }

    // (a) 주문 생성: DB 상태는 PENDING
    Map<String, Object> order = new HashMap<>();
    order.put("userId", userId);
    order.put("status", "PENDING");
    order.put("totalAmount", total);
    order.put("address", address);
    order.put("postcode", postcode);
    orderMapper.insertOrder(order);               // ✅ OrderMapper 사용

    Long orderId = orderMapper.selectCurrOrderId(); // 동일 세션 CURRVAL
    if (orderId == null) {
      ra.addFlashAttribute("error", "주문ID 생성에 실패했습니다");
      return "redirect:/bookstore/cart";
    }

    // (b) 주문 항목 스냅샷 저장(단가/수량) — 재고 차감은 아직 X
    for (Map.Entry<Long, Integer> e : wanted.entrySet()) {
      Long bookId = e.getKey(); int qty = e.getValue();
      BigDecimal unitPrice = BigDecimal.valueOf(bookMap.get(bookId).getPrice());
      orderMapper.insertOrderItem(orderId, bookId, qty, unitPrice);  // ✅ 파라미터 방식
    }

    // (c) 결제 중복방지 토큰(세션 저장)
    String token = UUID.randomUUID().toString();
    req.getSession().setAttribute("PAY_TOKEN_" + orderId, token);

    // 결제창으로 이동
    return "redirect:/bookstore/checkout?orderId=" + orderId + "&token=" + token;
  }

  /** 2) 결제창 표시(PENDING + 세션 토큰 필수) */
  @GetMapping("/checkout")
  public String checkoutPage(@RequestParam Long orderId,
                             @RequestParam(required = false) String token,
                             Principal principal,
                             Model model, HttpServletRequest req,
                             HttpServletResponse res,
                             RedirectAttributes ra) {

    if (principal == null) {
      ra.addFlashAttribute("error", "다시 로그인해주세요");
      return "redirect:/loginForm";
    }

    // 뒤로가기 캐시 금지
    res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    res.setHeader("Pragma", "no-cache");
    res.setDateHeader("Expires", 0);

    Long userId = userMapper.findUserIdByLoginId(principal.getName());
    Map<String, Object> order = orderMapper.findOrderForUser(orderId, userId); // ✅
    if (order == null) {
      ra.addFlashAttribute("error", "주문을 찾을 수 없습니다");
      return "redirect:/bookstore/cart";
    }

    // 상태 체크: PENDING만 결제 가능
    String status = String.valueOf(order.get("status"));
    if (!"PENDING".equals(status)) {
      req.getSession().removeAttribute("PAY_TOKEN_" + orderId);
      return "redirect:/bookstore/order/complete?orderId=" + orderId;
    }

    // 토큰 반드시 존재 & URL의 token과 일치
    String sess = (String) req.getSession().getAttribute("PAY_TOKEN_" + orderId);
    if (sess == null) {
      ra.addFlashAttribute("error", "결제 세션이 만료되었습니다. 다시 시도해주세요.");
      return "redirect:/bookstore/cart";
    }
    if (token != null && !token.equals(sess)) {
      ra.addFlashAttribute("error", "잘못된 접근입니다.");
      return "redirect:/bookstore/cart";
    }

    List<Map<String, Object>> items = orderMapper.findOrderItemsByOrderId(orderId); // ✅
    model.addAttribute("order", order);
    model.addAttribute("items", items);
    model.addAttribute("payToken", sess);
    return "bookstore/checkout";
  }

  /** 3) 결제 처리(모의/PG 공통 진입점) */
  @PostMapping("/checkout/pay")
  @Transactional
  public String pay(@RequestParam Long orderId,
                    @RequestParam String method,
                    @RequestParam String payToken,
                    Principal principal,
                    HttpServletRequest req, HttpServletResponse res,
                    RedirectAttributes ra) {

    if (principal == null) {
      ra.addFlashAttribute("error", "다시 로그인해주세요");
      return "redirect:/loginForm";
    }

    // 토큰(idempotency) 검증
    String sess = (String) req.getSession().getAttribute("PAY_TOKEN_" + orderId);
    if (sess == null || !sess.equals(payToken)) {
      ra.addFlashAttribute("error", "토큰 오류");
      return "redirect:/bookstore/checkout?orderId=" + orderId;
    }

    Long userId = userMapper.findUserIdByLoginId(principal.getName());
    Map<String, Object> order = orderMapper.findOrderForUser(orderId, userId); // ✅
    if (order == null) {
      ra.addFlashAttribute("error", "주문이 없습니다");
      return "redirect:/bookstore/cart";
    }

    String status = String.valueOf(order.get("status"));
    if (!"PENDING".equals(status)) {
      return "redirect:/bookstore/order/complete?orderId=" + orderId; // 이미 처리됨
    }

    List<Map<String, Object>> items = orderMapper.findOrderItemsByOrderId(orderId); // ✅

    // 서버 재계산 + 재고 최종 점검
    BigDecimal recalculated = BigDecimal.ZERO;
    for (Map<String, Object> it : items) {
      long bookId = ((Number) it.get("bookId")).longValue();
      int qty = ((Number) it.get("quantity")).intValue();
      BigDecimal unitPrice = (BigDecimal) it.get("unitPrice");

      Book b = bookMapper.findBookById(bookId);
      if (b.getStock() == null || b.getStock() < qty) {
        ra.addFlashAttribute("error", "결제 중 품절된 상품이 있습니다");
        return "redirect:/bookstore/checkout?orderId=" + orderId;
      }

      recalculated = recalculated.add(unitPrice.multiply(BigDecimal.valueOf(qty)));
    }
    BigDecimal orderTotal = (BigDecimal) order.get("totalAmount");
    if (recalculated.compareTo(orderTotal) != 0) {
      ra.addFlashAttribute("error", "금액 변경이 감지되었습니다");
      return "redirect:/bookstore/checkout?orderId=" + orderId;
    }

    // (모의) 결제 승인 → 재고 차감
    for (Map<String, Object> it : items) {
      long bookId = ((Number) it.get("bookId")).longValue();
      int qty = ((Number) it.get("quantity")).intValue();
      int updated = bookMapper.decreaseStock(bookId, qty);
      if (updated == 0) {
        ra.addFlashAttribute("error", "결제 중 품절되었습니다");
        return "redirect:/bookstore/checkout?orderId=" + orderId;
      }
    }

    // 상태 변경: PAID  (결제수단 저장 컬럼이 없으므로 method는 로그/추후 확장용)
    orderMapper.updateOrderStatus(orderId, "PAID"); // ✅ 시그니처 변경

    // 장바구니 쿠키 삭제 + 토큰 폐기
    clearCartCookie(res);
    clearCartCookieRoot(res);
    req.getSession().removeAttribute("PAY_TOKEN_" + orderId);

    return "redirect:/bookstore/order/complete?orderId=" + orderId;
  }

  /** cart 쿠키 → Map 변환 */
  private Map<Long, Integer> readCartCookieToWantedMap(HttpServletRequest req) {
    String raw = null;
    if (req.getCookies() != null) {
      for (Cookie c : req.getCookies()) {
        if ("cart".equals(c.getName())) { raw = c.getValue(); break; }
      }
    }
    if (raw == null || raw.isEmpty()) return Collections.emptyMap();

    try {
      byte[] decoded = Base64.getDecoder().decode(raw);
      String json = URLDecoder.decode(new String(decoded, StandardCharsets.UTF_8), "UTF-8");
      JsonNode root = om.readTree(json);

      Map<Long, Integer> wanted = new LinkedHashMap<>();
      if (root.has("i") && root.get("i").isArray()) {
        for (JsonNode n : root.get("i")) {
          if (!n.has("id")) continue;
          long id = n.get("id").asLong();
          int q = n.has("q") ? n.get("q").asInt() : 1;
          if (id <= 0) continue;
          q = Math.max(1, q);
          wanted.merge(id, q, Integer::sum);
        }
      }
      return wanted;
    } catch (Exception ignore) {
      return Collections.emptyMap();
    }
  }

  private void clearCartCookie(HttpServletResponse res) {
    Cookie cart = new Cookie("cart", "");
    cart.setPath("/bookstore");
    cart.setMaxAge(0);
    cart.setHttpOnly(false);
    res.addCookie(cart);
  }

  private void clearCartCookieRoot(HttpServletResponse res) {
    Cookie cart = new Cookie("cart", "");
    cart.setPath("/");
    cart.setMaxAge(0);
    cart.setHttpOnly(false);
    res.addCookie(cart);
  }

  // 주문 완료 페이지 (결제 후 진입점)
  @GetMapping("/order/complete")
  public String orderComplete(@RequestParam("orderId") Long orderId,
                              Principal principal,
                              Model model,
                              RedirectAttributes ra) {
    if (principal == null) {
      ra.addFlashAttribute("error", "다시 로그인해주세요");
      return "redirect:/loginForm";
    }
    Long userId = userMapper.findUserIdByLoginId(principal.getName());

    Map<String, Object> order = orderMapper.findOrderForUser(orderId, userId); // ✅
    if (order == null) {
      ra.addFlashAttribute("error", "주문을 찾을 수 없습니다");
      return "redirect:/bookstore/cart";
    }

    List<Map<String, Object>> items = orderMapper.findOrderItemsByOrderId(orderId); // ✅
    model.addAttribute("order", order);
    model.addAttribute("items", items);

    // 파일명이 정확히 orderComplete.jsp 인지 확인!!
    return "bookstore/orderComplete";
  }

  /** 주소 입력 폼: 장바구니 비어도 '바로구매' 쿼리는 허용 */
  @GetMapping("/checkoutForm")
  public String checkoutForm(@RequestParam(value = "error", required = false) String error,
                             @RequestParam(value = "bookId", required = false) Long bookId,
                             @RequestParam(value = "qty",    required = false) Integer qty,
                             Model model,
                             HttpServletRequest req,
                             HttpServletResponse res,
                             RedirectAttributes ra) {
    // 뒤로가기 캐시 방지
    res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    res.setHeader("Pragma", "no-cache");
    res.setDateHeader("Expires", 0);

    // 장바구니/바로구매 체크
    Map<Long, Integer> wanted = readCartCookieToWantedMap(req);
    if (wanted.isEmpty() && bookId == null) {
      ra.addFlashAttribute("error", "장바구니가 비어있습니다");
      return "redirect:/bookstore/cart";
    }

    // 바로구매 값 모델에 담기
    if (bookId != null) {
      model.addAttribute("buyNowBookId", bookId);
      model.addAttribute("buyNowQty", (qty == null ? 1 : Math.max(1, Math.min(99, qty))));
    }

    model.addAttribute("error", error);
    return "bookstore/checkoutForm";
  }
}
