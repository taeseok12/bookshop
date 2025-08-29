package service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import mapper.UserMapper;
import model.User;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder; // Security Config에서 @Bean 설정 가정

    /** loginId -> userId로 변환 */
    public Long getUserIdByLoginId(String loginId){
        return userMapper.findUserIdByLoginId(loginId);
    }

    /** 프로필 조회 */
    public User getProfile(Long userId){
        return userMapper.findByUserId(userId);
    }

    /** 프로필 수정 (name/email/hp) */
    public void updateProfile(Long userId, String name, String email, String hp){
        User u = new User();
        u.setUserId(userId);
        u.setName(name);
        u.setEmail(email);
        u.setHp(hp);
        userMapper.updateUser(u);
    }

    /** 비밀번호 변경 (기존 비번 확인) */
    public void changePassword(Long userId, String currentRaw, String nextRaw){
        String hash = userMapper.findPasswordHashByUserId(userId);
        if (hash == null || !passwordEncoder.matches(currentRaw, hash)) {
            throw new IllegalArgumentException("현재 비밀번호가 일치하지 않습니다.");
        }
        String encoded = passwordEncoder.encode(nextRaw);
        userMapper.updatePassword(userId, encoded);
    }
}