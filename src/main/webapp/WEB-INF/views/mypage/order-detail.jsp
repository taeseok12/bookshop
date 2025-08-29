<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
  :root{
    --ink:#0f172a; --muted:#6b7280; --line:#e7eaf1; --card:#fff;
    --brand:#5965ff; --ok:#22c55e; --warn:#f59e0b; --bad:#ef4444;
    --radius:12px;
  }
  *{box-sizing:border-box}
  .od-wrap{max-width:1040px;margin:0 auto;padding:8px}
  .od-head{display:flex;align-items:center;justify-content:space-between;background:var(--card);border:1px solid var(--line);border-radius:var(--radius);padding:16px;margin-bottom:16px}
  .od-title{font-size:18px;font-weight:800;margin:0;color:var(--ink)}
  .od-sub{color:var(--muted);font-size:14px;margin-top:4px}
  .badge{padding:4px 10px;border-radius:999px;font-size:12px;border:1px solid var(--line);background:#f8fafc}
  .badge.PENDING{background:#f1f5f9}
  .badge.PAID{background:#ecfdf5;border-color:#bbf7d0}
  .badge.SHIPPED{background:#eef2ff;border-color:#c7d2fe}
  .badge.DELIVERED{background:#f5f3ff;border-color:#ddd6fe}
  .badge.CANCELLED{background:#fef2f2;border-color:#fecaca}
  .od-actions{display:flex;gap:8px;flex-wrap:wrap}
  .btn{display:inline-block;padding:8px 12px;border:1px solid var(--line);border-radius:10px;background:#fff;cursor:pointer;text-decoration:none;color:var(--ink)}
  .btn.primary{background:var(--brand);color:#fff;border-color:var(--brand)}
  .btn.danger{background:var(--bad);color:#fff;border-color:var(--bad)}
  .od-grid{display:grid;grid-template-columns:1.2fr .8fr;gap:16px}
  .card{background:var(--card);border:1px solid var(--line);border-radius:var(--radius);padding:16px}
  .card h3{margin:0 0 10px 0}
  table.od-items{width:100%;border-collapse:collapse}
  table.od-items th, table.od-items td{padding:12px 8px;border-bottom:1px solid #eef1f6}
  table.od-items th{color:var(--muted);font-weight:600;text-align:left}
  table.od-items td:nth-child(2),
  table.od-items td:nth-child(3),
  table.od-items td:nth-child(4){text-align:right;white-space:nowrap}
  .thumb{width:56px;height:80px;object-fit:cover;border-radius:8px;border:1px solid var(--line);margin-right:12px}
  .flex{display:flex;align-items:center}
  .muted{color:var(--muted)}
  .split{display:flex;justify-content:space-between;align-items:center;margin:6px 0}
  .hr{border:none;border-top:1px solid #eef1f6;margin:16px 0}
  .title-link{color:var(--ink);text-decoration:none}
  .title-link:hover{text-decoration:underline}
</style>

<div class="od-wrap">

  <!-- 상단 헤더 -->
  <div class="od-head">
    <div>
      <h2 class="od-title">주문 #${orderHeader.orderId}</h2>
      <div class="od-sub">
        <fmt:formatDate value="${orderHeader.orderDate}" pattern="yyyy-MM-dd HH:mm"/>
        · <span class="badge ${orderHeader.status}">${orderHeader.status}</span>
      </div>
    </div>
    <div class="od-actions">
      <!-- 상태별 액션 -->
      <c:if test="${orderHeader.status == 'PENDING' || orderHeader.status == 'PAID'}">
        <a class="btn" href="${ctx}/bookstore/mypage/order/${orderHeader.orderId}/address">배송지 변경</a>
        <form method="post" action="${ctx}/bookstore/mypage/order/${orderHeader.orderId}/cancel" style="display:inline">
          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
          <button type="submit" class="btn danger">주문취소</button>
        </form>
      </c:if>

      <c:if test="${orderHeader.status == 'SHIPPED'}">
        <c:if test="${not empty orderHeader.trackingNo}">
          <a class="btn" target="_blank"
             href="${ctx}/bookstore/mypage/track?c=${orderHeader.courier}&t=${orderHeader.trackingNo}">배송조회</a>
        </c:if>
        <form method="post" action="${ctx}/bookstore/mypage/order/${orderHeader.orderId}/confirm" style="display:inline">
          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
          <button type="submit" class="btn primary">수령확인</button>
        </form>
      </c:if>

      <a class="btn" href="${ctx}/bookstore/mypage/orders">목록으로</a>
    </div>
  </div>

  <!-- 상품 합계 계산(초기값 0) -->
  <c:set var="subtotal" value="${0}" />
  <c:forEach var="it" items="${items}">
    <c:set var="subtotal" value="${subtotal + (it.unitPrice * it.quantity)}"/>
  </c:forEach>
  <!-- 총 결제금액 폴백: header.totalAmount 없으면 subtotal 사용 -->
  <c:set var="grand" value="${empty orderHeader.totalAmount ? subtotal : orderHeader.totalAmount}"/>

  <!-- 본문: 좌(상품/금액) · 우(결제/배송) -->
  <div class="od-grid">

    <!-- 좌측: 상품 목록 -->
    <div class="card">
      <h3>주문 상품</h3>

      <c:choose>
        <c:when test="${empty items}">
          <p class="muted">주문 상품이 없습니다.</p>
        </c:when>
        <c:otherwise>
          <table class="od-items">
            <thead>
              <tr>
                <th>도서</th>
                <th>단가</th>
                <th>수량</th>
                <th>합계</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="it" items="${items}">
                <c:set var="rowTotal" value="${it.unitPrice * it.quantity}"/>
                <tr>
                  <td>
                    <div class="flex">
                      <c:if test="${not empty it.coverImage}">
                        <img class="thumb" src="${it.coverImage}" alt="${it.bookTitle}"/>
                      </c:if>
                      <div>
                        <div><a class="title-link" href="${ctx}/bookstore/book/${it.bookId}">${it.bookTitle}</a></div>
                        <div class="muted" style="font-size:13px">
                          <a class="muted" href="${ctx}/bookstore/books?author=${fn:escapeXml(it.author)}">${it.author}</a>
                        </div>
                      </div>
                    </div>
                  </td>
                  <td><fmt:formatNumber value="${it.unitPrice}"/> 원</td>
                  <td>${it.quantity}</td>
                  <td><fmt:formatNumber value="${rowTotal}"/> 원</td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- 우측: 결제 금액 + 배송 정보 -->
    <div class="card">
      <h3>결제 금액</h3>
      <div class="split"><span class="muted">상품 합계</span>
        <span><fmt:formatNumber value="${subtotal}"/> 원</span>
      </div>
      <%-- 할인/배송비 사용 시 아래를 열어 쓰세요
      <div class="split"><span class="muted">배송비</span><span>0 원</span></div>
      <div class="split"><span class="muted">할인</span><span>- 0 원</span></div>
      --%>
      <div class="hr"></div>
      <div class="split" style="font-weight:800">
        <span>총 결제금액</span>
        <span><fmt:formatNumber value="${grand}"/> 원</span>
      </div>

      <div class="hr"></div>

      <h3>배송 정보</h3>
      <c:choose>
        <c:when test="${not empty orderHeader.address}">
          <div class="muted">주소</div>
          <div style="margin-bottom:8px">${orderHeader.address}</div>
          <div class="muted">우편번호</div>
          <div style="margin-bottom:8px">${orderHeader.postcode}</div>
          <c:if test="${not empty orderHeader.trackingNo}">
            <div class="muted">송장번호</div>
            <div style="margin-bottom:8px">${orderHeader.trackingNo}</div>
          </c:if>
          <c:if test="${not empty orderHeader.courier}">
            <div class="muted">택배사</div>
            <div>${orderHeader.courier}</div>
          </c:if>
        </c:when>
        <c:otherwise>
          <p class="muted" style="margin-top:6px">배송지가 아직 입력되지 않았습니다.</p>
          <c:if test="${orderHeader.status == 'PENDING' || orderHeader.status == 'PAID'}">
            <a class="btn" href="${ctx}/bookstore/mypage/order/${orderHeader.orderId}/address">배송지 입력/변경</a>
          </c:if>
        </c:otherwise>
      </c:choose>
    </div>

  </div>
</div>