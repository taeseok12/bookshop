<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="sec"
	uri="http://www.springframework.org/security/tags"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>북마켓 메인</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

</head>
<body>
	<div class="welcome-box">
		<h1 class="display-4">로그인 성공</h1>
		<h4>
			<c:choose>
				<c:when test="${not empty sessionScope.loginId}">
					<span>${sessionScope.loginId}님, 환영합니다</span>
				</c:when>
				<c:otherwise>
					<span>로그인 후 이용해 주세요.</span>
				</c:otherwise>
			</c:choose>
		</h4>

		<div class="mt-4">
			<a href="${pageContext.request.contextPath}/bookstore/books"
				class="btn btn-light btn-lg me-2">메인화면</a>
			<form action="${pageContext.request.contextPath}/logout"
				method="post">
				<input type="hidden" name="${_csrf.parameterName}"
					value="${_csrf.token}" />
				<button type="submit" class="btn btn-light btn-lg me-2">로그아웃</button>
			</form>
		</div>
	</div>
</body>
</html>