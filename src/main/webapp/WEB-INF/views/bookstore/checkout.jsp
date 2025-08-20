<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>결제</title>
<style>
    body {
      font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial;
      margin: 24px;
      color: #000;
    }
    h1 {
      font-size: 24px;
      margin-bottom: 16px;
    }
    .container {
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
    .section-title {
      font-weight: 700;
      margin-bottom: 12px;
    }
    .muted {
      font-size: 13px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 8px;
    }
    th, td {
      padding: 8px;
      text-align: left;
      border-bottom: 1px solid #000;
    }
    th {
      font-weight: 700;
    }
    .right {
      text-align: right;
    }
    .total {
      font-weight: 700;
    }
    .row {
      display: flex;
      justify-content: space-between;
      margin: 6px 0;
    }
    .error {
      color: #000;
      margin-bottom: 10px;
    }
  </style>
</head>
<body>

<h1>결제</h1>

<c:if test="${not empty param.error}">
  <p class="error"><c:out value="${param.error}"/></p>
</c:if>

<div class="layout">

  <!-- 좌측: 주문/상품 정보 -->
  <div class="card">
    <div class="section-title">배송지 정보</div>
    <div class="row"><span class="muted">회원</span><span>${order.name}</span></div>
    <div class="row"><span class="muted">주소</span><span><c:out value="${order.address}"/></span></div>
    <div class="row"><span class="muted">우편번호</span><span><c:out value="${order.postcode}"/></span></div>
    <div class="row"><span class="muted">주문번호</span><span class="badge">#${order.orderId}</span></div>


    <table>
      <thead>
        <tr>
          <th>도서명</th>
          <th class="right">수량</th>
          <th class="right">가격</th>
          <th class="right">합계</th>
        </tr>
      </thead>
      <tbody>
      <c:set var="sum" value="0"/>
      <c:forEach var="it" items="${items}">
        <c:set var="subtotal" value="${it.unitPrice * it.quantity}"/>
        <tr>
          <td><c:out value="${it.title}"/></td>
          <td class="right"><c:out value="${it.quantity}"/></td>
          <td class="right"><fmt:formatNumber value="${it.unitPrice}" type="number"/></td>
          <td class="right"><fmt:formatNumber value="${subtotal}" type="number"/></td>
        </tr>
        <c:set var="sum" value="${sum + subtotal}"/>
      </c:forEach>
      </tbody>
      <tfoot>
        <tr>
          <th colspan="3" class="right">총액</th>
          <th class="right"><fmt:formatNumber value="${sum}" type="number"/></th>
        </tr>

      </tfoot>
    </table>
    <p class="muted" style="margin-top:8px;">
    </p>
  </div>

  <!-- 우측: 결제 옵션/버튼 -->
  <div class="card">
    <div class="section-title">결제</div>

    <form id="payForm" method="post" action="<c:url value='/bookstore/checkout/pay'/>">
      <!-- CSRF -->
      <c:if test="${not empty _csrf}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
      </c:if>

      <!-- 필수 파라미터: 컨트롤러와 매칭 -->
      <input type="hidden" name="orderId"  value="${order.orderId}"/>
      <input type="hidden" name="payToken" value="${payToken}"/>


      <div class="row">
        <span class="total"><fmt:formatNumber value="${order.totalAmount}" type="number"/>원</span>
      </div>

      <button id="payBtn" type="submit" class="btn btn-primary">결제하기</button>
    </form>

    <c:if test="${not empty payToken}">
      <p class="muted" style="margin-top:12px;"></p>
    </c:if>
  </div>

</div>

<script>
  // 이중 클릭 방지
  document.getElementById('payForm').addEventListener('submit', function (e) {
    var btn = document.getElementById('payBtn');
    btn.disabled = true;
    btn.textContent = '결제 요청 중...';
  });
</script>

</body>
</html>
