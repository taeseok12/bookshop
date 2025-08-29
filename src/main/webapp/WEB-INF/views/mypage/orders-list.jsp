<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="baseUrl" value="${ctx}/bookstore/mypage/orders" />
<c:set var="detailUrlBase" value="${ctx}/bookstore/mypage/orderDetail" />
<c:set var="emptyOrders" value="${empty orders}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>주문 내역</title>
  <style>
    :root{
      --bg:#f5f7fb; --card:#fff; --bd:#e6e8ec; --txt:#0f172a; --muted:#6b7280;
      --hover:rgba(17,24,39,.06);
      --ok-bg:#ecfdf5; --ok-bd:#a7f3d0; --ok:#065f46;
      --ship-bg:#eff6ff; --ship-bd:#bfdbfe; --ship:#1e40af;
      --pend-bg:#fffbeb; --pend-bd:#fde68a; --pend:#92400e;
      --cancel-bg:#fef2f2; --cancel-bd:#fecaca; --cancel:#991b1b;
      --accent:#2e6eff;
      --radius:12px;
    }
    body{margin:0;background:var(--bg);color:var(--txt);font-family:system-ui,-apple-system,Segoe UI,Roboto,Apple SD Gothic Neo,Noto Sans KR,Malgun Gothic,sans-serif}
    .wrap{max-width:980px;margin:28px auto;padding:0 16px}
    .page-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:18px}
    .title{margin:0;font-size:22px;font-weight:800;letter-spacing:-.2px}

    /* 카드 */
    .card{position:relative;display:grid;grid-template-columns:84px 1fr auto;gap:14px;align-items:start;
      background:var(--card);border:1px solid var(--bd);border-radius:var(--radius);padding:14px 16px;margin-bottom:12px}
    .card:hover{box-shadow:0 4px 16px var(--hover);border-color:#d9dde3}
    .thumb{width:84px;height:118px;border-radius:10px;object-fit:cover;background:#f2f3f5}
    .main{min-width:0}
    .line{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
    .no{font-weight:800}
    .dot{color:#cbd5e1}
    .date{color:var(--muted)}
    .badge{padding:2px 8px;border-radius:999px;font-size:12px;line-height:18px;border:1px solid transparent;user-select:none}
    .badge.PAID{background:var(--ok-bg);color:var(--ok);border-color:var(--ok-bd)}
    .badge.SHIPPED{background:var(--ship-bg);color:var(--ship);border-color:var(--ship-bd)}
    .badge.PENDING{background:var(--pend-bg);color:var(--pend);border-color:var(--pend-bd)}
    .badge.CANCELLED{background:var(--cancel-bg);color:var(--cancel);border-color:var(--cancel-bd)}

    .title2{margin-top:6px;font-weight:700;letter-spacing:-.2px;
      display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
    .meta{display:flex;align-items:center;gap:10px;margin-top:6px}
    .receiver{color:var(--muted)}
    .spacer{flex:1}
    .amount{font-weight:800}

    .cta{align-self:start;border:1px solid #d1d5db;border-radius:10px;padding:8px 12px;color:var(--txt);text-decoration:none;white-space:nowrap;background:#fff}
    .cta:hover{background:#f9fafb}
    /* stretched link for full-card click */
    .stretch{position:absolute;inset:0;border-radius:inherit;text-indent:-9999px}
    .card:focus-within{outline:2px solid #bcd2ff;outline-offset:2px}

    /* Empty */
    .empty{background:var(--card);border:1px dashed var(--bd);border-radius:var(--radius);padding:40px 20px;text-align:center;color:var(--muted)}
    .btn{display:inline-block;margin-top:10px;padding:10px 16px;border-radius:10px;background:var(--accent);color:#fff;text-decoration:none;font-weight:700}

    /* Pagination */
    .pager{display:flex;gap:6px;justify-content:center;align-items:center;margin:20px 0 8px}
    .pager a,.pager span{padding:6px 10px;border:1px solid #d0d0d0;border-radius:8px;text-decoration:none;color:var(--txt);font-size:14px;background:#fff}
    .pager .active{background:var(--accent);border-color:var(--accent);color:#fff}
    .pager .disabled{pointer-events:none;opacity:.45}

    @media (max-width:640px){
      .card{grid-template-columns:72px 1fr}
      .cta{grid-column:1/-1;justify-self:end}
    }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="page-head">
      <h1 class="title">주문 내역</h1>
    </div>
	
	<c:set var="ctx" value="${pageContext.request.contextPath}" />
	
	
    <c:choose>
      <c:when test="${emptyOrders}">
        <div class="empty">
          주문내역이 없습니다.<br/>마음에 드는 책을 찾아보세요.
          <a class="btn" href="${ctx}/bookstore/books">책 보러가기</a>
        </div>
      </c:when>

      <c:otherwise>
        <!-- 상단 페이지 네비 -->
<%--         <jsp:include page="/WEB-INF/views/common/_pager.jsp">
          <jsp:param name="baseUrl" value="${baseUrl}"/>
        </jsp:include> --%>
        

        <c:forEach var="order" items="${orders}">
          <c:set var="coverSrc" value="${empty order.firstBookCover ? ctx+'/static/img/book-placeholder.png' : order.firstBookCover}" />

          <article class="card">
            <img class="thumb"
                 src="${coverSrc}"
                 alt="대표 도서 표지"
                 loading="lazy"
                 width="84" height="118"/>

            <div class="main">
              <div class="line">
                <span class="no">주문 #<c:out value="${order.orderId}"/></span>
                <span class="dot">•</span>
                <time class="date"><fmt:formatDate value="${order.orderDate}" pattern="yyyy-MM-dd HH:mm"/></time>
                <span class="badge ${order.status}"><c:out value="${order.status}"/></span>
              </div>

              <div class="title2">
                <c:choose>
                  <c:when test="${order.totalBookCount > 1}">
                    <c:out value="${order.firstBookTitle}"/> 외 <c:out value="${order.totalBookCount - 1}"/>권
                  </c:when>
                  <c:otherwise>
                    <c:out value="${order.firstBookTitle}"/>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="meta">
                <span class="receiver"><c:out value="${order.receiverName}"/></span>
                <span class="spacer"></span>
                <span class="amount"><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/> 원</span>
              </div>
            </div>

            <a class="cta" href="${detailUrlBase}/${order.orderId}" aria-label="주문 #${order.orderId} 상세보기">상세보기</a>
            <a class="stretch" href="${detailUrlBase}/${order.orderId}" aria-hidden="true" tabindex="-1">전체 클릭</a>
          </article>
        </c:forEach>

        <!-- 하단 페이지 네비 (직접 포함) -->
        <c:set var="page" value="${page}" />
        <c:set var="size" value="${size}" />
        <c:set var="totalPages" value="${totalPages}" />
        <c:set var="hasPrev" value="${hasPrev}" />
        <c:set var="hasNext" value="${hasNext}" />

        <c:set var="beginPage" value="${page-2 < 1 ? 1 : page-2}" />
        <c:set var="endPage"   value="${page+2 > totalPages ? totalPages : page+2}" />

        <nav class="pager" aria-label="페이지 네비게이션">
          <a class="${page == 1 ? 'disabled' : ''}" href="${baseUrl}?page=1&size=${size}" aria-label="첫 페이지">« 처음</a>
          <a class="${!hasPrev ? 'disabled' : ''}" href="${baseUrl}?page=${page-1 < 1 ? 1 : page-1}&size=${size}" aria-label="이전 페이지">‹ 이전</a>

          <c:forEach var="p" begin="${beginPage}" end="${endPage}">
            <c:choose>
              <c:when test="${p == page}">
                <span class="active" aria-current="page">${p}</span>
              </c:when>
              <c:otherwise>
                <a href="${baseUrl}?page=${p}&size=${size}">${p}</a>
              </c:otherwise>
            </c:choose>
          </c:forEach>

          <a class="${!hasNext ? 'disabled' : ''}" href="${baseUrl}?page=${page+1 > totalPages ? totalPages : page+1}&size=${size}" aria-label="다음 페이지">다음 ›</a>
          <a class="${page == totalPages || totalPages == 0 ? 'disabled' : ''}" href="${baseUrl}?page=${totalPages}&size=${size}" aria-label="마지막 페이지">마지막 »</a>
        </nav>
      </c:otherwise>
    </c:choose>
  </div>
</body>
</html>