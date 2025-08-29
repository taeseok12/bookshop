package login;

import java.io.IOException;
import java.util.Collection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import mapper.UserMapper;
import model.User;

public class CustomerLoginSuccessHandler implements AuthenticationSuccessHandler {

    @Autowired
    private UserMapper usermapper;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest req,
                                        HttpServletResponse res,
                                        Authentication auth) throws IOException {
        // 1) 로그인한 사용자 아이디
        String loginId = auth.getName();

        // 2) DB에서 회원 정보 조회 (표시명 등 세션에 저장)
        User user = usermapper.findByUsername(loginId);
        if (user != null) {
            req.getSession().setAttribute("loginId", loginId);
            req.getSession().setAttribute("loginName", user.getName());
        } else {
            // 사용자 정보가 없으면 로그인 폼으로 되돌림
            res.sendRedirect(req.getContextPath() + "/loginForm?error=true");
            return;
        }

        // 3) 권한에 따라 리다이렉트 (관리자 우선)
        Collection<? extends GrantedAuthority> auths = auth.getAuthorities();
        boolean isAdmin = auths.stream().anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()));
        boolean isCustomer = auths.stream().anyMatch(a -> "ROLE_CUSTOMER".equals(a.getAuthority()));

        if (isAdmin) {
            res.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } else if (isCustomer) {
            res.sendRedirect(req.getContextPath() + "/bookstore/books");
        } else {
            // 예상치 못한 권한일 경우
            res.sendRedirect(req.getContextPath() + "/loginForm?error=true");
        }

        // 디버깅 로그
        System.out.println("[로그인 성공] 사용자 ID: " + loginId +
                           ", 이름: " + user.getName() +
                           ", 권한: " + auths);
    }
}
