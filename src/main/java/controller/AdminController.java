package controller;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private service.AdminService adminService;
    
    private final ObjectMapper om = new ObjectMapper();

    /** /admin -> /admin/dashboard */
    @GetMapping
    public String adminRoot() {
        return "redirect:/admin/dashboard";
    }

    /** 관리자 대시보드 
     * @throws JsonProcessingException */
    @GetMapping("/dashboard")
    public String dashboard(Model model) throws JsonProcessingException {
        model.addAttribute("stats", adminService.getDashboardStats());
        
     // 차트 데이터 조회
        List<Map<String,Object>> daily  = adminService.getDailySalesLast30();
        List<Map<String,Object>> monthly= adminService.getMonthlySalesLast12();
        List<Map<String,Object>> status = adminService.getOrderStatusCounts();
        Map<String,Object> invBuckets   = adminService.getInventoryBuckets();

        // JSON으로 변환(escape 안 하게 JSP에서 그대로 출력)
        model.addAttribute("dailySalesJson",   om.writeValueAsString(daily));
        model.addAttribute("monthlySalesJson", om.writeValueAsString(monthly));
        model.addAttribute("statusJson",       om.writeValueAsString(status));
        model.addAttribute("inventoryJson",    om.writeValueAsString(invBuckets));

        return "admin/dashboard";
    }

    
    /** 회원 관리 목록 (+ 검색/필터) */
    @GetMapping("/users")
    public String users(@RequestParam(required = false) String keyword,
                        @RequestParam(required = false) String role,
                        Model model) {
        model.addAttribute("users", adminService.findUsers(keyword, role));
        return "admin/users";
    }
    /** 권한 변경 (ROLE_CUSTOMER / ROLE_ADMIN) */
    @PostMapping("/users/role")
    public String changeRole(@RequestParam Long userId,
                             @RequestParam String role) {
        adminService.changeUserRole(userId, role);
        return "redirect:/admin/users";
    }
    /** 활성/비활성 토글 (active = 'Y' | 'N') */
    @PostMapping("/users/active")
    public String changeActive(@RequestParam Long userId,
                               @RequestParam String active) {
        adminService.changeUserActive(userId, active);
        return "redirect:/admin/users";
    }

    
    /** 도서 관리 목록 */
    @GetMapping("/books")
    public String books(@RequestParam(required = false) String keyword,
                        Model model) {
        model.addAttribute("books", adminService.findBooks(keyword));
        return "admin/books";
    }
    // 빠른 수정(가격/재고)
    /** 도서 수정 폼 */
    @GetMapping("/books/edit")
    public String editBook(@RequestParam("bookId") Long bookId, Model model) {
        model.addAttribute("book", adminService.getBook(bookId));
        model.addAttribute("mode", "update");
        return "admin/book-form";
    }
    /** 등록 저장 */
    @PostMapping("/books/create")
    public String createBook(@RequestParam java.util.Map<String,Object> form) {
        adminService.createBook(form); // title, author, price, stock, description?, cover_image?
        return "redirect:/admin/books";
    }
    /** 수정 저장 (폼/인라인 모두 이 엔드포인트 사용) */
    @PostMapping("/books/update")
    public String updateBook(@RequestParam java.util.Map<String,Object> form) {
        adminService.updateBook(form); // book_id 필수, 나머지는 선택
        return "redirect:/admin/books";
    }
    /** 삭제 */
    @PostMapping("/books/delete")
    public String deleteBook(@RequestParam("bookId") Long bookId) {
        adminService.deleteBook(bookId);
        return "redirect:/admin/books";
    }
    

    /** 주문 관리 목록 */
    @GetMapping("/orders")
    public String orders(@RequestParam(required = false) String status,
                         Model model) {
        model.addAttribute("orders", adminService.findOrders(status));
        return "admin/orders";
    }
    /** 주문 상태 변경 (PENDING/PAID/SHIPPED/DELIVERED/CANCELLED) */
    @PostMapping("/orders/status")
    public String changeOrderStatus(@RequestParam("orderId") Long orderId,
                                    @RequestParam("status")  String status,
                                    RedirectAttributes ra) {
        Set<String> allowed = new HashSet<>(Arrays.asList("PENDING","PAID","SHIPPED","DELIVERED","CANCELLED"));
        if (!allowed.contains(status)) {
            ra.addFlashAttribute("error", "허용되지 않은 상태입니다: " + status);
            return "redirect:/admin/orders";
        }

        int updated = adminService.updateOrderStatus(orderId, status);
        if (updated > 0) ra.addFlashAttribute("msg", "주문 #" + orderId + " 상태가 " + status + "로 변경되었습니다.");
        else             ra.addFlashAttribute("error", "상태 변경 실패(주문 없음).");
        return "redirect:/admin/orders";
    }


    /** 송장/택배사 저장
     *  - JSP에서 name="orderId" or "order_id", "trackingNo" or "tracking_no" 모두 지원
     */
    @PostMapping({"/orders/update", "/orders/courier"})
    public String updateOrderCourier(@RequestParam(value="orderId", required=false) Long orderId1,
                                     @RequestParam(value="order_id", required=false) Long orderId2,
                                     @RequestParam(value="courier", required=false) String courier,
                                     @RequestParam(value="trackingNo", required=false) String trackingNo1,
                                     @RequestParam(value="tracking_no", required=false) String trackingNo2,
                                     RedirectAttributes ra) {

        Long orderId = (orderId1 != null ? orderId1 : orderId2);
        String trackingNo = (trackingNo1 != null ? trackingNo1 : trackingNo2);

        if (orderId == null) {
            ra.addFlashAttribute("error", "orderId가 필요합니다.");
            return "redirect:/admin/orders";
        }

        int updated = adminService.updateOrderCourier(orderId, courier, trackingNo);
        if (updated > 0) ra.addFlashAttribute("msg", "주문 #" + orderId + " 송장 정보가 저장되었습니다.");
        else             ra.addFlashAttribute("error", "송장 저장 실패(주문 없음).");
        return "redirect:/admin/orders";
    }
}

