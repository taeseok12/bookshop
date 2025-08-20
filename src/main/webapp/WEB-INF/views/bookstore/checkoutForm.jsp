<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>배송 정보 입력</title>
  <style>
    body {
      font-family: 'Noto Sans KR', sans-serif;
      background:#fff;
      margin:0;
      padding:40px;
      color:#000;
    }
    .container {
      max-width:500px;
      margin:0 auto;
      background:#fff;
      padding:30px;
      border:1px solid #000;
      border-radius:10px;
    }
    h1 {
      font-size:1.5em;
      margin-bottom:20px;
      text-align:center;
      color:#000;
    }
    label {
      font-weight:600;
      display:block;
      margin-bottom:6px;
    }
    input[type=text] {
      width:100%;
      padding:10px;
      border:1px solid #000;
      border-radius:6px;
      font-size:1em;
      margin-bottom:18px;
      outline:none;
    }
    input[type=text]:focus {
      border-color:#000;
    }
    .error {
      color:#000;
      font-size:.9em;
      margin-bottom:15px;
      text-align:center;
    }
    button {
      display:block;
      width:100%;
      padding:12px;
      background:#000;
      color:#fff;
      border:none;
      border-radius:6px;
      font-size:1.05em;
      cursor:pointer;
    }
    button:hover {
      background:#333;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>배송지 입력</h1>

    <c:if test="${not empty error || not empty param.error}">
      <p class="error"><c:out value="${error != null ? error : param.error}"/></p>
    </c:if>

    <form action="${pageContext.request.contextPath}/bookstore/checkout/confirm" method="post">
      <!-- CSRF -->
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

      <label>주소</label>
      <input type="text" name="address" placeholder="도로명 주소" required/>

      <label>우편번호</label>
      <input type="text" name="postcode" placeholder="우편번호(5자리)" required pattern="[0-9]{5}" maxlength="5"/>

      <c:if test="${not empty buyNowBookId}">
        <input type="hidden" name="buyNowBookId" value="${buyNowBookId}"/>
        <input type="hidden" name="buyNowQty" value="${buyNowQty}"/>
      </c:if>

      <button type="submit">결제</button>
    </form>
  </div>

  <input type="hidden" name="bookId" value="${book.bookId}">
  <input type="hidden" name="qty" id="buyNowQty" value="1">
</body>
</html>
