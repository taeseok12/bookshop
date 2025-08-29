<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title><c:out value="${mode=='update' ? '도서 수정' : '도서 등록'}"/></title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  :root{ --bg:#f5f7fb; --white:#fff; --line:#e7ecf3; --text:#1f2a44 }
  body{margin:0;background:var(--bg);color:var(--text);font:14px/1.5 system-ui}
  .wrap{display:flex;min-height:100vh}
  .sidebar{width:240px;background:#0f172a;color:#cbd5e1;padding:16px 10px}
  .menu a{display:block;padding:10px 12px;border-radius:10px;color:#cbd5e1}
  .menu a:hover,.menu a.active{background:#111c38;color:#fff}
  .main{flex:1;padding:18px}
  .card{background:#fff;border:1px solid var(--line);border-radius:14px;padding:16px;max-width:840px}
  .row{display:grid;grid-template-columns:150px 1fr;gap:10px;align-items:center;margin-bottom:10px}
  .input, textarea{width:100%;border:1px solid var(--line);border-radius:10px;padding:8px}
  .btn{background:#111c38;color:#fff;border:none;border-radius:10px;padding:10px 14px;font-weight:700;cursor:pointer}
  .toolbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
</style>
</head>
<body>

<div class="wrap">
  <aside class="sidebar">
    <div style="color:#fff;font-weight:700;padding:10px 12px">📚 Bookshop Admin</div>
    <nav class="menu">
      <a href="${pageContext.request.contextPath}/admin/dashboard">대시보드</a>
      <a href="${pageContext.request.contextPath}/admin/users">사용자 관리</a>
      <a class="active" href="${pageContext.request.contextPath}/admin/books">도서 관리</a>
      <a href="${pageContext.request.contextPath}/admin/orders">주문 관리</a>
    </nav>
  </aside>

  <main class="main">
    <div class="toolbar">
      <h2 style="margin:0">
        <c:out value="${mode=='update' ? '도서 수정' : '도서 등록'}"/>
      </h2>
      <a class="btn" href="${pageContext.request.contextPath}/admin/books">목록</a>
    </div>

    <div class="card">
      <form method="post"
            action="${pageContext.request.contextPath}/admin/books/${mode=='update' ? 'update' : 'create'}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <c:if test="${mode=='update'}">
          <input type="hidden" name="book_id" value="${book.bookId}">
        </c:if>

        <div class="row">
          <label>제목 *</label>
          <input class="input" type="text" name="title" value="${book.title}" required>
        </div>
        <div class="row">
          <label>저자 *</label>
          <input class="input" type="text" name="author" value="${book.author}" required>
        </div>
        <div class="row">
          <label>가격(원) *</label>
          <input class="input" type="number" name="price" min="0" step="100" value="${book.price}" required>
        </div>
        <div class="row">
          <label>재고 *</label>
          <input class="input" type="number" name="stock" min="0" value="${book.stock}" required>
        </div>
        <div class="row">
          <label>표지 이미지 URL</label>
          <input class="input" type="url" name="cover_image" value="${book.coverImage}">
        </div>
        <div class="row" style="align-items:start">
          <label>설명</label>
          <textarea name="description" rows="8">${book.description}</textarea>
        </div>

        <div style="text-align:right;margin-top:12px">
          <button class="btn" type="submit">${mode=='update' ? '수정 저장' : '등록'}</button>
        </div>
      </form>
    </div>
  </main>
</div>

</body>
</html>
