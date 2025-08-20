<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title><c:out value="${book.title}"/> - 상세보기</title>
<style>
  :root {
    --primary: #5a4ad1;
    --primary-hover: #4339b0;
    --primary-bg-light: #f0f0ff;
    --border: #ccc;
  }

  body {
    font-family: 'Noto Sans KR', sans-serif;
    margin: 0;
    padding: 0;
    background: #fafafa;
    color: #333;
  }

  .container {
    max-width: 800px;
    margin: 40px auto;
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    border: 1px solid #eee;
  }

  .book-header {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
  }

  .cover {
    width: 200px;
    height: 300px;
    background-size: cover;
    background-position: center;
    border-radius: 6px;
    border: 1px solid var(--border);
    flex-shrink: 0;
  }

  .book-info h1 {
    margin: 0 0 10px 0;
    font-size: 1.6rem;
  }

  .book-info p {
    margin: 5px 0;
  }

  .out {
    color: #dc3545;
    font-weight: 600;
  }

  .btn-area {
    margin-top: 15px;
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    align-items: center;
  }

  .btn {
    padding: 10px 16px;
    border-radius: 6px;
    font-size: 14px;
    cursor: pointer;
    border: 1px solid transparent;
    text-decoration: none;
  }

  .btn-solid {
    background: var(--primary);
    color: #fff;
  }

  .btn-solid:hover {
    background: var(--primary-hover);
  }

  .btn-outline {
    background: var(--primary-bg-light);
    color: var(--primary);
    border-color: var(--border);
  }

  .btn-outline:hover {
    filter: brightness(0.95);
  }

  .btn[disabled] {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .qty {
    display: flex;
    align-items: center;
    gap: 5px;
  }

  .qty input {
    width: 70px;
    padding: 6px 8px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 14px;
  }

  .book-description {
    margin-top: 25px;
    line-height: 1.6;
  }

  hr {
    margin: 25px 0;
    border: 0;
    border-top: 1px solid #eee;
  }
</style>

</head>
<body>
  <div class="container">
    <div class="book-header">
      <div class="cover" style="background-image:url('<c:out value="${book.coverImage}"/>');"></div>

      <div class="book-info">
        <h1><c:out value="${book.title}"/></h1>
        <p>저자: <c:out value="${book.author}"/></p>
        <p class="price"><c:out value="${book.price}"/>원</p>

        <c:choose>
          <c:when test="${book.stock gt 0}">
            <p class="stock">재고: <c:out value="${book.stock}"/>권</p>

            <!-- 버튼/수량 -->
            <div class="btn-area">
              <div class="qty">
                <label for="qty">수량</label>
                <input id="qty" type="number" min="1"
                       value="1"
                       max="${book.stock > 0 ? book.stock : 1}">
              </div>
              
              <p>

              <!-- 장바구니 -->
              <button type="button" class="btn btn-outline"
                      onclick="addToCart(${book.bookId}, getQty())">
                장바구니 담기
              </button>
              

              <!-- 결제 -->
              <form id="buyNowForm" method="get"
                    action="${pageContext.request.contextPath}/bookstore/checkoutForm"
                    style="display:inline">
                <input type="hidden" name="bookId" value="${book.bookId}">
                <input type="hidden" name="qty" id="buyNowQty" value="1">
                <button type="submit" class="btn btn-solid">결제</button>
              </form>

              <a href="${pageContext.request.contextPath}/bookstore/cart" class="btn btn-outline">장바구니 목록</a>
              <a href="${pageContext.request.contextPath}/bookstore/books" class="btn btn-outline">도서 목록</a>
            </div>
          </c:when>

          <c:otherwise>
            <p class="out">재고없음</p>
            <div class="btn-area">
              <button class="btn btn-outline" disabled>장바구니</button>
              <button class="btn btn-solid" disabled>바로구매</button>
              <a href="${pageContext.request.contextPath}/bookstore/books" class="btn btn-outline">목록으로</a>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <div class="book-description">
      <h2>책 소개</h2>
      <p><c:out value="${book.description}"/></p>
    </div>
  </div>

<script>
// 재고 한도
const MAX_STOCK = ${book.stock != null ? book.stock : 0};

// v2(Base64) cart cookie 읽기
function readCart(){
  const m = document.cookie.match(/(?:^|;\s*)cart=([^;]+)/);
  if(!m) return { i: [] };
  try {
    return JSON.parse(decodeURIComponent(atob(m[1])));
  } catch(e){
    try { return JSON.parse(decodeURIComponent(m[1])); } catch(e2){ return { i: [] }; }
  }
}

function writeCart(cart){
  const v = btoa(encodeURIComponent(JSON.stringify(cart)));
  const maxAge = 60*60*24*14;
  // 구버전 Path=/ 제거
  document.cookie = 'cart=; Path=/; Max-Age=0; SameSite=Lax';
  document.cookie = 'cart=' + v + '; Path=/bookstore; Max-Age=' + maxAge + '; SameSite=Lax';
}

function clampQty(q, max){
  q = parseInt(q || '1', 10);
  if (isNaN(q)) q = 1;
  q = Math.max(1, q);
  if (typeof max === 'number' && max > 0) q = Math.min(max, q);
  return q;
}

function getQty(){
  const input = document.getElementById('qty');
  const q = clampQty(input.value, MAX_STOCK);
  input.value = q; // 화면값 보정
  const hidden = document.getElementById('buyNowQty');
  if (hidden) hidden.value = q; // 바로구매 hidden 동기화
  return q;
}

function addToCart(id, qty){
  const c = readCart();
  const hit = c.i.find(x => x.id === id);
  const q = clampQty(qty, MAX_STOCK);
  if(hit) hit.q = Math.min(99, hit.q + q);
  else c.i.push({ id, q: Math.min(99, q) });
  writeCart(c);
  alert('장바구니에 담았습니다');
}

// 입력 즉시 hidden 값 동기화
const qtyEl = document.getElementById('qty');
if (qtyEl) {
  qtyEl.addEventListener('input', getQty);
  qtyEl.addEventListener('change', getQty);
}
</script>
</body>
</html>