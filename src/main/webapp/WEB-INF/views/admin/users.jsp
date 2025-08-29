<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>회원 관리</title>
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
  /* Sidebar (대시보드와 동일한 톤) */
  .sidebar{width:240px;background:#0f172a;color:#cbd5e1;padding:16px 10px;border-right:1px solid #0b1326;position:sticky;top:0;height:100vh}
  .brand{display:flex;align-items:center;gap:8px;color:#fff;font-weight:700;font-size:18px;padding:10px 12px}
  .menu a{display:block;padding:10px 12px;border-radius:10px;color:#cbd5e1}
  .menu a:hover,.menu a.active{background:#111c38;color:#fff}

  /* Main */
  .main{flex:1;display:flex;gap:20px;padding:18px}
  .content{flex:1}
  .card{background:var(--white);border:1px solid var(--line);border-radius:14px;padding:14px}

  /* 헤더 / 필터 */
  .toolbar{display:flex;gap:10px;align-items:center;justify-content:space-between;margin-bottom:12px}
  .title{font-size:18px;font-weight:800}
  .filters{display:flex;gap:8px;align-items:center}
  .input, .select{
    background:#fff;border:1px solid var(--line);border-radius:10px;padding:8px 10px;min-width:180px
  }
  .btn{background:#111c38;color:#fff;border:none;border-radius:10px;padding:8px 12px;font-weight:700;cursor:pointer}
  .btn.gray{background:#eef2ff;color:#1d4ed8;border:1px solid #dbe2ff}
  .btn.green{background:var(--success)}
  .btn.red{background:var(--danger)}
  .badge{display:inline-block;padding:2px 8px;border-radius:999px;font-size:12px}
  .badge.admin{background:#eef2ff;color:#1d4ed8;border:1px solid #dbe2ff}
  .badge.customer{background:#ecfdf5;color:#065f46;border:1px solid #bbf7d0}
  .badge.active{background:#ecfdf5;color:#065f46;border:1px solid #bbf7d0}
  .badge.inactive{background:#fff7ed;color:#9a3412;border:1px solid #fed7aa}

  /* Table */
  table{width:100%;border-collapse:collapse}
  th,td{padding:10px;border-bottom:1px solid var(--line);text-align:left;vertical-align:middle}
  th{color:#64748b;font-weight:700;font-size:12px;letter-spacing:.3px}
  td.actions{white-space:nowrap}
  .muted{color:var(--muted)}
</style>
</head>
<body>

<div class="wrap">
  <!-- LEFT -->
  <aside class="sidebar">
    <div class="brand">📚 Bookshop Admin</div>
    <nav class="menu">
      <a href="${pageContext.request.contextPath}/admin/dashboard">대시보드</a>
      <a class="active" href="${pageContext.request.contextPath}/admin/users">사용자 관리</a>
      <a href="${pageContext.request.contextPath}/admin/books">도서 관리</a>
      <a href="${pageContext.request.contextPath}/admin/orders">주문 관리</a>
    </nav>
  </aside>

  <!-- CENTER -->
  <main class="main">
    <section class="content">
      <div class="toolbar">
        <div class="title">사용자 관리</div>
        <form method="get" action="${pageContext.request.contextPath}/admin/users" class="filters">
          <input class="input" type="text" name="keyword" value="${param.keyword}" placeholder="이름/아이디/이메일 검색">
          <select class="select" name="role">
            <option value="">전체 권한</option>
            <option value="ROLE_CUSTOMER" <c:if test="${param.role=='ROLE_CUSTOMER'}">selected</c:if>>ROLE_CUSTOMER</option>
            <option value="ROLE_ADMIN"    <c:if test="${param.role=='ROLE_ADMIN'}">selected</c:if>>ROLE_ADMIN</option>
          </select>
          <button class="btn gray" type="submit">검색</button>
        </form>
      </div>

      <div class="card">
        <table>
          <thead>
            <tr>
              <th style="width:90px">회원 ID</th>
              <th>로그인 ID</th>
              <th>이름</th>
              <th>이메일</th>
              <th style="width:140px">권한</th>
              <th style="width:120px">상태</th>
              <th style="width:260px">관리</th>
            </tr>
          </thead>
          <tbody>
          <c:forEach var="u" items="${users}">
            <tr>
              <td>${u.userId}</td>
              <td>${u.loginId}<div class="muted">${u.hp}</div></td>
              <td>${u.name}</td>
              <td>${u.email}</td>

              <!-- 권한 뱃지 -->
              <td>
                <c:choose>
                  <c:when test="${u.role == 'ROLE_ADMIN'}">
                    <span class="badge admin">ROLE_ADMIN</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge customer">ROLE_CUSTOMER</span>
                  </c:otherwise>
                </c:choose>
              </td>

              <!-- 활성 상태 -->
              <td>
                <c:choose>
                  <c:when test="${u.active == 'Y'}">
                    <span class="badge active">Active</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge inactive">Inactive</span>
                  </c:otherwise>
                </c:choose>
              </td>

              <!-- 액션 -->
              <td class="actions">
                <!-- 권한 변경 -->
                <form style="display:inline" method="post" action="${pageContext.request.contextPath}/admin/users/role">
                  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                  <input type="hidden" name="userId" value="${u.userId}">
                  <select name="role" class="select" style="min-width:150px">
                    <option value="ROLE_CUSTOMER" <c:if test="${u.role=='ROLE_CUSTOMER'}">selected</c:if>>ROLE_CUSTOMER</option>
                    <option value="ROLE_ADMIN"    <c:if test="${u.role=='ROLE_ADMIN'}">selected</c:if>>ROLE_ADMIN</option>
                  </select>
                  <button class="btn" type="submit" title="권한 변경">변경</button>
                </form>

                <!-- Active/Inactive 토글 -->
                <form style="display:inline;margin-left:6px" method="post" action="${pageContext.request.contextPath}/admin/users/active">
                  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                  <input type="hidden" name="userId" value="${u.userId}">
                  <input type="hidden" name="active" value="<c:out value='${u.active == "Y" ? "N" : "Y"}'/>">
                  <c:choose>
                    <c:when test="${u.active == 'Y'}">
                      <button class="btn red" type="submit" title="로그인 비활성화">비활성화</button>
                    </c:when>
                    <c:otherwise>
                      <button class="btn green" type="submit" title="로그인 활성화">활성화</button>
                    </c:otherwise>
                  </c:choose>
                </form>
              </td>
            </tr>
          </c:forEach>

          <c:if test="${empty users}">
            <tr><td colspan="7" style="color:#94a3b8;text-align:center">조회된 회원이 없습니다.</td></tr>
          </c:if>
          </tbody>
        </table>
      </div>
    </section>
  </main>
</div>

</body>
</html>
