<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입 성공</title>

    <!-- Bootstrap CDN -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">

    <!-- Google Fonts & Animation -->
    <link href="https://fonts.googleapis.com/css2?family=Nanum+Gothic&display=swap" rel="stylesheet">

</head>
<body>

<div class="card">
    <h2 class="mb-4"> 회원가입 성공</h2>
 
    <a href="${pageContext.request.contextPath}/loginForm" class="mb-4"">로그인 하기</a>
</div>

</body>
</html>
