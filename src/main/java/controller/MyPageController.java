package controller;


import java.security.Principal;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import dto.PageCriteria;
import dto.PageResult;
import lombok.RequiredArgsConstructor;
import lombok.experimental.var;
import lombok.extern.slf4j.Slf4j;
import model.OrderHeader;
import model.OrderItemView;
import model.OrderSummary;
import model.User;
import service.OrderService;
import service.UserService;

@SuppressWarnings("deprecation")
@Controller
@RequestMapping("/mypage")
@RequiredArgsConstructor
@Slf4j
public class MyPageController {

    private final UserService userService;
    private final OrderService orderService;

    /** 로그인된 사용자 ID 가져오기 */
    private Long currentUserId(Principal principal){
        if (principal == null) throw new IllegalStateException("로그인이 필요합니다.");
        return userService.getUserIdByLoginId(principal.getName());
    }

    /** 기본 마이페이지 (회원 프로필) */
    @GetMapping("")
    public String mypageHome(Model model, Principal principal){
        Long userId = currentUserId(principal);
        User member = userService.getProfile(userId);
        model.addAttribute("member", member);
        model.addAttribute("pageContent", "/WEB-INF/views/mypage/profile.jsp");
        return "mypage/mypage";
    }

    /** 뒤에 슬래시도 허용 */
    @GetMapping("/")
    public String mypageHomeSlash(){
        return "redirect:/bookstore/mypage";
    }

    /** 내 정보 수정 폼 */
    @GetMapping("/edit")
    public String editForm(Model model, Principal principal){
        Long userId = currentUserId(principal);
        User member = userService.getProfile(userId);
        model.addAttribute("member", member);
        model.addAttribute("pageContent", "/WEB-INF/views/mypage/edit.jsp");
        return "mypage/mypage";
    }

    /** 내 정보 수정 처리 */
    @PostMapping("/edit")
    public String editSubmit(@RequestParam String name,
                             @RequestParam String email,
                             @RequestParam(required=false) String hp,
                             Principal principal){
        Long userId = currentUserId(principal);
        userService.updateProfile(userId, name, email, hp);
        return "redirect:/bookstore/mypage";
    }

    @GetMapping("/orders")
    public String orders(@RequestParam(defaultValue = "1") Integer page,
                         @RequestParam(defaultValue = "10") Integer size,
                         Principal principal,
                         Model model) {
        Long userId = currentUserId(principal);

        PageCriteria criteria = new PageCriteria(page, size);
        PageResult<OrderSummary> result = orderService.getMyOrders(userId, criteria);

        boolean empty = result.getContent() == null || result.getContent().isEmpty();
        model.addAttribute("orders", result.getContent());
        model.addAttribute("empty", empty);
        model.addAttribute("page", result.getPage());
        model.addAttribute("size", result.getSize());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("hasPrev", result.isHasPrev());
        model.addAttribute("hasNext", result.isHasNext());
        model.addAttribute("pageContent", "/WEB-INF/views/mypage/orders-list.jsp");
        return "mypage/mypage";
    }


    /** 주문 상세보기 (최종 경로: /bookstore/mypage/orderDetail/{orderId}) */
//    @GetMapping("/orderDetail/{orderId}")
//    public String orderDetail(@PathVariable Long orderId,
//                              Principal principal,
//                              Model model) {
//        Long userId = currentUserId(principal); // 목록 화면에서 쓰던 것과 동일한 방식 사용!
//
//        // 헤더
//        var header = orderService.getOrderHeader(orderId, userId);
//        if (header == null) {
//            model.addAttribute("statusCode", 404);
//            model.addAttribute("message", "주문을 찾을 수 없습니다.");
//            model.addAttribute("pageContent", "/WEB-INF/views/error/404.jsp");
//            return "mypage/mypage";
//        }
//
//        // 아이템
//        var items = orderService.getOrderItems(orderId, userId);
//        if (items == null) items = java.util.Collections.emptyList();
//
//        // 폴백: header에 주소가 비어 있으면 아이템 첫 건에서 보충
//        if ((header.getAddress() == null || header.getAddress().isBlank()) && !items.isEmpty()) {
//            var first = items.get(0);
//            header.setAddress(first.getAddress());
//        }
//        if ((header.getPostcode() == null || header.getPostcode().isBlank()) && !items.isEmpty()) {
//            var first = items.get(0);
//            header.setPostcode(first.getPostcode());
//        }
//
//        model.addAttribute("header", header);
//        model.addAttribute("items", items);
//        model.addAttribute("pageContent", "/WEB-INF/views/mypage/order-detail.jsp");
//        return "mypage/mypage";
//    }
    @GetMapping("/orderDetail/{orderId}")
    public String orderDetail(@PathVariable("orderId") Long orderId,
                              Principal principal,
                              Model model) {
        Long userId = userService.getUserIdByLoginId(principal.getName());

        OrderHeader header = orderService.getOrderHeader(orderId, userId);
        List<OrderItemView> items = orderService.getOrderItems(orderId, userId);

        // 디버깅 로그
        log.debug("header = {}", header);
        log.debug("items = {}", items);

        model.addAttribute("orderHeader", header);
        model.addAttribute("items", items);
        model.addAttribute("pageContent", "/WEB-INF/views/mypage/order-detail.jsp");
        return "mypage/mypage";
    }


    /** 프로젝트에서 실제로 쓰는 방식과 동일하게 구현하세요 */
    private Long currentUserIdLong(Principal principal) {
        if (principal == null) throw new RuntimeException("로그인이 필요합니다.");
        // ⚠️ principal.getName()이 login_id라면 숫자 변환하면 안 됩니다.
        // 반드시 기존 목록 컨트롤러에서 쓰던 로직과 동일하게 userId를 구하세요.
        // 예) return userService.findUserIdByLoginId(principal.getName());
        return Long.valueOf(principal.getName()); // 임시. 실제 방식으로 교체!
    }
    
}