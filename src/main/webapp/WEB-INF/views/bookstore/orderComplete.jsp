<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>주문 완료</title>
  <style>
    body{font-family:'Noto Sans KR',sans-serif;margin:0;background:#f9f9f9}
    .wrap{max-width:720px;margin:60px auto;background:#fff;padding:28px;border-radius:12px;box-shadow:0 6px 18px rgba(0,0,0,.06)}
    h1{margin:0 0 12px}
    .actions{margin-top:24px;display:flex;gap:10px}
    a.btn{display:inline-block;padding:10px 14px;border-radius:8px;background:#222;color:#fff;text-decoration:none}
  </style>
</head>
<body>
  <div class="wrap">
    <h1>주문 완료</h1>
    <div class="actions">
      <a class="btn" href="${pageContext.request.contextPath}/bookstore/books">메인 화면</a>
    </div>
  </div>

  <script>
    // 보조: 혹시 남아 있을 수 있는 cart 쿠키들을 JS로 한 번 더 제거
    document.cookie = 'cart=; Path=/bookstore; Max-Age=0; SameSite=Lax';
    document.cookie = 'cart=; Path=/; Max-Age=0; SameSite=Lax'; // 과거 레거시 경로 대응
  </script>
</body>
</html>
