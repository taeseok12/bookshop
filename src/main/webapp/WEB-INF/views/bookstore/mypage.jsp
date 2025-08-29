<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>마이페이지 | BookMarket</title>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" rel="stylesheet">
  <style>
    body { font-family:'Noto Sans KR', sans-serif; margin:0; background:#f8f9fa; color:#333; }
    .container { max-width:1200px; margin:0 auto; padding:20px; }
    h2 { margin-top:40px; font-size:20px; border-bottom:2px solid #ddd; padding-bottom:8px; }
    table { width:100%; border-collapse:collapse; margin-top:15px; }
    table th, table td { border:1px solid #ddd; padding:8px; text-align:center; }
    .profile-box { background:#fff; padding:20px; border-radius:8px; box-shadow:0 2px 6px rgba(0,0,0,0.1); }
    .btn { padding:6px 12px; background:#4a55d6; color:#fff; border:none; border-radius:4px; cursor:pointer; }
  </style>
</head>
<body>
<div class="container">

  <!-- 1. 프로필 영역 -->
  <div class="profile-box">
    <h2>내 정보</h2>
    <p>이름: ${user.name}</p>
    <p>이메일: ${user.email}</p>
    <p>전화번호: ${user.hp}</p>
    <p>회원등급: ${user.role}</p>
    <button class="btn">정보 수정</button>
  </div>

  <!-- 2. 장바구니 -->
  <h2>🛒 장바구니</h2>
  <c:if test="${empty cartItems}">
    <p>장바구니가 비어 있습니다.</p>
  </c:if>
  <c:if test="${not empty cartItems}">
    <table>
      <thead>
        <tr>
          <th>도서명</th>
          <th>수량</th>
          <th>가격</th>
          <th>합계</th>
          <th>삭제</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="item" items="${cartItems}">
          <tr>
            <td>${item.book.title}</td>
            <td>${item.quantity}</td>
            <td><fmt:formatNumber value="${item.book.price}" type="number"/> 원</td>
            <td><fmt:formatNumber value="${item.book.price * item.quantity}" type="number"/> 원</td>
            <td><a href="cart/delete?itemId=${item.id}" class="btn">삭제</a></td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
    <button class="btn">주문하기</button>
  </c:if>

  <!-- 3. 주문 내역 -->
  <h2>📦 주문 내역</h2>
  <c:if test="${empty orders}">
    <p>주문 내역이 없습니다.</p>
  </c:if>
  <c:if test="${not empty orders}">
    <table>
      <thead>
        <tr>
          <th>주문번호</th>
          <th>주문일</th>
          <th>총금액</th>
          <th>상태</th>
          <th>상세보기</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="order" items="${orders}">
          <tr>
            <td>${order.id}</td>
            <td><fmt:formatDate value="${order.orderDate}" pattern="yyyy-MM-dd"/></td>
            <td><fmt:formatNumber value="${order.totalAmount}" type="number"/> 원</td>
            <td>${order.status}</td>
            <td><a href="orders/${order.id}" class="btn">보기</a></td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </c:if>

  <!-- 4. 계정 설정 -->
  <h2>⚙ 계정 설정</h2>
  <ul>
    <li><a href="user/update">이메일 / 전화번호 수정</a></li>
    <li><a href="user/password">비밀번호 변경</a></li>
    <li><a href="user/delete">회원 탈퇴</a></li>
  </ul>

</div>
</body>
</html>