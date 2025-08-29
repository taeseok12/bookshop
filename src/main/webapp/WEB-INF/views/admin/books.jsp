<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>도서 관리</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  :root{
    --bg:#f5f7fb; --white:#fff; --muted:#7b8aa3; --text:#1f2a44;
    --line:#e7ecf3; --primary:#2563eb; --success:#13b981; --danger:#ef4444;
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--text);font:14px/1.5 "Pretendard",system-ui,-apple-system,Segoe UI,Roboto,"Noto Sans KR",Arial}
  a{color:inherit;text-decoration:none}

  .wrap{display:flex;min-height:100vh}
  /* Sidebar (users.jsp와 동일 톤) */
  .sidebar{width:240px;background:#0f172a;color:#cbd5e1;padding:16px 10px;border-right:1px solid #0b1326;position:sticky;top:0;height:100vh}
  .brand{display:flex;align-items:center;gap:8px;color:#fff;font-weight:700;font-size:18px;padding:10px 12px}
  .menu a{display:block;padding:10px 12px;border-radius:10px;color:#cbd5e1}
  .menu a:hover,.menu a.active{background:#111c38;color:#fff}

  /* Main */
  .main{flex:1;display:flex;gap:20px;padding:18px}
  .content{flex:1}
  .card{background:var(--white);border:1px solid var(--line);border-radius:14px;padding:14px}

  /* 헤더/필터 */
  .toolbar{display:flex;gap:10px;align-items:center;justify-content:space-between;margin-bottom:12px}
  .title{font-size:18px;font-weight:800}
  .filters{display:flex;gap:8px;align-items:center}
  .input, .select{background:#fff;border:1px solid var(--line);border-radius:10px;padding:8px 10px;min-width:220px}
  .btn{background:#111c38;color:#fff;border:none;border-radius:10px;padding:8px 12px;font-weight:700;cursor:pointer}
  .btn.gray{background:#eef2ff;color:#1d4ed8;border:1px solid #dbe2ff}
  .btn.green{background:var(--success)}
  .btn.red{background:var(--danger)}

  /* Table */
  table{width:100%;border-collapse:collapse}
  th,td{padding:10px;border-bottom:1px solid var(--line);text-align:left;vertical-align:middle}
  th{color:#64748b;font-weight:700;font-size:12px;letter-spacing:.3px}
  td.actions{white-space:nowrap}
  .cover{width:42px;height:58px;object-fit:cover;border-radius:6px;border:1px solid var(--line);background:#fff}
  .muted{color:var(--muted)}
  .stock-low{color:#b45309;font-weight:700}
  .stock-zero{color:#ef4444;font-weight:700}
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
      <a class="active" href="${pageContext.request.contextPath}/admin/books">도서 관리</a>
      <a href="${pageContext.request.contextPath}/admin/orders">주문 관리</a>
    </nav>
  </aside>

  <!-- CENTER -->
  <main class="main">
    <section class="content">

      <!-- 툴바 -->
      <div class="toolbar">
        <div class="title">도서 관리</div>
        <div>
          <form method="get" action="${pageContext.request.contextPath}/admin/books" class="filters">
            <input class="input" type="text" name="keyword" value="${param.keyword}" placeholder="제목/저자 검색">
            <button class="btn gray" type="submit">검색</button>
            <!-- (선택) 도서 추가 페이지가 생기면 연결 -->
            <a class="btn" href="${pageContext.request.contextPath}/admin/books/new" style="margin-left:6px">+ 도서 등록</a>
          </form>
        </div>
      </div>

      <!-- 목록 -->
      <div class="card">
        <table>
          <thead>
            <tr>
              <th style="width:80px">ID</th>
              <th style="width:70px">표지</th>
              <th>제목</th>
              <th>저자</th>
              <th style="width:140px">가격</th>
              <th style="width:120px">재고</th>
              <th style="width:240px">관리</th>
            </tr>
          </thead>
          <tbody>
          <c:forEach var="b" items="${books}">
            <tr>
              <td>${b.bookId}</td>
              <td>
                <c:choose>
                  <c:when test="${not empty b.coverImage}">
                    <img class="cover" src="${b.coverImage}" alt="${b.title}">
                  </c:when>
                  <c:otherwise>
                    <div class="cover" style="display:flex;align-items:center;justify-content:center;font-size:11px;color:#94a3b8">No Image</div>
                  </c:otherwise>
                </c:choose>
              </td>
              <td>
                <div style="font-weight:700">${b.title}</div>
                <div class="muted" style="font-size:12px;max-width:520px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                  <c:out value="${b.description}"/>
                </div>
              </td>
              <td>${b.author}</td>
              <td>
                <fmt:formatNumber value="${b.price}" type="number"/> 원
              </td>
	            <td>
				  <c:set var="stockVal" value="${b.stock}" />
				  <c:choose>
				    <c:when test="${stockVal == null}">
				      -
				    </c:when>
				    <c:when test="${stockVal == 0}">
				      <span class="stock-zero">품절(0)</span>
				    </c:when>
				    <c:when test="${stockVal gt 0 and stockVal le 5}">
				      <span class="stock-low">${stockVal}</span>
				    </c:when>
				    <c:otherwise>
				      ${stockVal}
				    </c:otherwise>
				  </c:choose>
				</td>
              <td class="actions">
                <!-- (예시) 가격/재고 빠른 수정 -->
                <form method="post" action="${pageContext.request.contextPath}/admin/books/update" style="display:inline">
                  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                  <input type="hidden" name="book_id" value="${b.bookId}">
                  <input class="input" style="width:110px" type="number" name="price" min="0" step="100" placeholder="가격(원)">
                  <input class="input" style="width:90px"  type="number" name="stock" min="0" placeholder="재고">
                  <button class="btn green" type="submit">저장</button>
                </form>

                <!-- (예시) 삭제 -->
                <form method="post" action="${pageContext.request.contextPath}/admin/books/delete" style="display:inline;margin-left:6px"
                      onsubmit="return confirm('해당 도서를 삭제하시겠습니까? 주문내역과 연결된 경우 삭제가 제한될 수 있습니다.');">
                  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                  <input type="hidden" name="bookId" value="${b.bookId}">
                  <button class="btn red" type="submit">삭제</button>
                </form>
                
                  <!-- 수정폼 이동 -->
				  <a class="btn gray" href="${pageContext.request.contextPath}/admin/books/edit?bookId=${b.bookId}"
				     style="margin-left:6px">수정폼</a>
              </td>
            </tr>
          </c:forEach>

          <c:if test="${empty books}">
            <tr><td colspan="7" style="color:#94a3b8;text-align:center">조회된 도서가 없습니다.</td></tr>
          </c:if>
          </tbody>
        </table>
      </div>

    </section>
  </main>
</div>

</body>
</html>
