<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>주문 관리</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  :root{
    --bg:#f5f7fb; --white:#fff; --muted:#7b8aa3; --text:#1f2a44;
    --line:#e7ecf3; --primary:#2563eb; --success:#13b981; --danger:#ef4444; --warn:#f59e0b;
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--text);font:14px/1.5 "Pretendard",system-ui,-apple-system,Segoe UI,Roboto,"Noto Sans KR",Arial}
  a{color:inherit;text-decoration:none}

  .wrap{display:flex;min-height:100vh}
  .sidebar{width:240px;background:#0f172a;color:#cbd5e1;padding:16px 10px;border-right:1px solid #0b1326;position:sticky;top:0;height:100vh}
  .brand{display:flex;align-items:center;gap:8px;color:#fff;font-weight:700;font-size:18px;padding:10px 12px}
  .menu a{display:block;padding:10px 12px;border-radius:10px;color:#cbd5e1}
  .menu a:hover,.menu a.active{background:#111c38;color:#fff}

  .main{flex:1;display:flex;gap:20px;padding:18px}
  .content{flex:1}
  .card{background:var(--white);border:1px solid var(--line);border-radius:14px;padding:14px}

  .toolbar{display:flex;gap:10px;align-items:center;justify-content:space-between;margin-bottom:12px}
  .title{font-size:18px;font-weight:800}
  .filters{display:flex;gap:8px;align-items:center}
  .select,.input{background:#fff;border:1px solid var(--line);border-radius:10px;padding:8px 10px;min-width:200px}
  .btn{background:#111c38;color:#fff;border:none;border-radius:10px;padding:8px 12px;font-weight:700;cursor:pointer}
  .btn.gray{background:#eef2ff;color:#1d4ed8;border:1px solid #dbe2ff}
  .btn.green{background:var(--success)}
  .btn.red{background:var(--danger)}

  table{width:100%;border-collapse:collapse}
  th,td{padding:10px;border-bottom:1px solid var(--line);text-align:left;vertical-align:middle}
  th{color:#64748b;font-weight:700;font-size:12px;letter-spacing:.3px}
  td.actions{white-space:nowrap}

  .badge{display:inline-block;padding:4px 10px;border-radius:999px;font-size:12px;border:1px solid transparent}
  .badge.PENDING   {background:#fff7ed;color:#9a3412;border-color:#fed7aa}
  .badge.PAID      {background:#ecfdf5;color:#065f46;border-color:#bbf7d0}
  .badge.SHIPPED   {background:#eff6ff;color:#1e40af;border-color:#bfdbfe}
  .badge.DELIVERED {background:#eef2ff;color:#1d4ed8;border-color:#c7d2fe}
  .badge.CANCELLED {background:#fee2e2;color:#991b1b;border-color:#fecaca}

  .muted{color:var(--muted);font-size:12px}
</style>
</head>
<body>

<div class="wrap">
  <!-- LEFT -->
  <aside class="sidebar">
    <div class="brand">📚 Bookshop Admin</div>
    <nav class="menu">
      <a href="${pageContext.request.contextPath}/admin/dashboard">대시보드</a>
      <a href="${pageContext.request.contextPath}/admin/users">사용자 관리</a>
      <a href="${pageContext.request.contextPath}/admin/books">도서 관리</a>
      <a class="active" href="${pageContext.request.contextPath}/admin/orders">주문 관리</a>
    </nav>
  </aside>

  <!-- CENTER -->
  <main class="main">
    <section class="content">

      <!-- 툴바 -->
      <div class="toolbar">
        <div class="title">주문 관리</div>
        <form method="get" action="${pageContext.request.contextPath}/admin/orders" class="filters">
          <select class="select" name="status">
            <option value="">전체 상태</option>
            <option value="PENDING"   <c:if test="${param.status=='PENDING'}">selected</c:if>>PENDING</option>
            <option value="PAID"      <c:if test="${param.status=='PAID'}">selected</c:if>>PAID</option>
            <option value="SHIPPED"   <c:if test="${param.status=='SHIPPED'}">selected</c:if>>SHIPPED</option>
            <option value="DELIVERED" <c:if test="${param.status=='DELIVERED'}">selected</c:if>>DELIVERED</option>
            <option value="CANCELLED" <c:if test="${param.status=='CANCELLED'}">selected</c:if>>CANCELLED</option>
          </select>
          <button class="btn gray" type="submit">필터</button>
        </form>
      </div>

      <!-- 목록 -->
      <div class="card">
        <table>
          <thead>
            <tr>
              <th style="width:90px">주문 ID</th>
              <th style="width:100px">회원 ID</th>
              <th style="width:130px">상태</th>
              <th style="width:140px">금액</th>
              <th style="width:170px">주문일</th>
              <th>송장/택배사</th>
              <th style="width:340px">관리</th>
            </tr>
          </thead>
          
         <tbody>
<c:forEach var="o" items="${orders}">
  <tr>
    <td>${o.orderId}</td>
    <td>${o.userId}</td>
    <td><span class="badge ${o.status}">${o.status}</span></td>
    <td><fmt:formatNumber value="${o.totalAmount}" type="number"/> 원</td>
    <td><fmt:formatDate value="${o.orderDate}" pattern="yyyy-MM-dd HH:mm"/></td>
    <td>
      <div><b>${o.trackingNo}</b></div>
      <div class="muted">${o.courier}</div>
    </td>

    <!-- ✅ 여기! 관리 액션 칸 -->
    <td class="actions">

      <!-- 상태 변경 폼 -->
      <form method="post" action="${pageContext.request.contextPath}/admin/orders/status" style="display:inline">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <input type="hidden" name="orderId" value="${o.orderId}">
        <select name="status" class="select" style="min-width:150px">
          <option value="PENDING"   <c:if test="${o.status=='PENDING'}">selected</c:if>>PENDING</option>
          <option value="PAID"      <c:if test="${o.status=='PAID'}">selected</c:if>>PAID</option>
          <option value="SHIPPED"   <c:if test="${o.status=='SHIPPED'}">selected</c:if>>SHIPPED</option>
          <option value="DELIVERED" <c:if test="${o.status=='DELIVERED'}">selected</c:if>>DELIVERED</option>
          <option value="CANCELLED" <c:if test="${o.status=='CANCELLED'}">selected</c:if>>CANCELLED</option>
        </select>
        <button class="btn green" type="submit">상태 저장</button>
      </form>

      <!-- 송장/택배사 저장 폼 -->
      <form method="post" action="${pageContext.request.contextPath}/admin/orders/update"
            style="display:inline;margin-left:6px">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <input type="hidden" name="order_id" value="${o.orderId}"><!-- snake_case도 컨트롤러에서 처리 -->
        <input class="input" style="width:140px" type="text" name="courier"     value="${o.courier}"     placeholder="택배사">
        <input class="input" style="width:160px" type="text" name="tracking_no" value="${o.trackingNo}" placeholder="송장번호">
        <button class="btn" type="submit">송장 저장</button>
      </form>

    </td>
  </tr>
</c:forEach>

<c:if test="${empty orders}">
  <tr><td colspan="7" style="color:#94a3b8;text-align:center">조회된 주문이 없습니다.</td></tr>
</c:if>
</tbody>

        </table>
      </div>

    </section>
  </main>
</div>

</body>
</html>
