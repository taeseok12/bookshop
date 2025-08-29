package mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import model.User;
import java.util.List;

@Mapper
public interface UserMapper {
    User findByUsername(@Param("loginId") String loginId);
    User findByEmail(String email);
    int existsByUsername(@Param("loginId") String loginId);
    int existsByEmail(@Param("email") String email);
    int insertUser(User user);
    List<String> findRolesByUserId(@Param("userId") Long userId);
    Long findUserIdByLoginId(@Param("loginId") String loginId);
    User findByUserId(@Param("userId") Long userId);
    int updatePassword(@Param("userId") Long userId, @Param("password") String password);
    int updateUser(User user);
    String findPasswordHashByUserId(@Param("userId") Long userId);     // 비번 해시만
}
 