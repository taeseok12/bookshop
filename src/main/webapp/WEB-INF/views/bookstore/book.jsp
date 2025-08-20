<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>BookMarket</title>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" rel="stylesheet">
  <style>
    *{box-sizing:border-box}
    body{margin:0;font-family:'Noto Sans KR',sans-serif;background:#f9f9f9;color:#333;padding-top:80px}
    :root{--primary:#3f51b5;--accent:#4caf50;--text-gray:#555;--bg-card:#fff;--shadow:rgba(0,0,0,.08)}

    header{position:fixed;top:0;left:0;right:0;height:80px;background:#fff;box-shadow:0 2px 8px var(--shadow);display:flex;align-items:center;padding:0 20px;z-index:1000}
    .logo{font-size:1.6em;font-weight:700;color:var(--primary)}
    .logo a{text-decoration:none;color:inherit}
    .text-btn {
  display:inline-flex;
  align-items:center;
  justify-content:center;
  padding:0 14px;
  height:40px;
  background:var(--primary);  /* 현재 짙은 파란색 #1a237e */
  color:#fff;
  border:0;
  border-radius:4px;
  font-size:.95em;
  text-decoration:none;
  cursor:pointer;
  margin-left:8px;
  white-space:nowrap;
  transition:filter .2s
}
    .text-btn:hover{filter:brightness(1.1)}
    /* 바로구매용 아웃라인 버튼 */
    .text-btn.outline{background:#fff;color:var(--primary);border:2px solid var(--primary)}

    .search-bar{flex:1;margin:0 20px;display:flex;position:relative}
    .search-bar input{flex:1;height:40px;padding:0 12px;border:1px solid #ccc;border-right:none;border-radius:20px 0 0 20px;font-size:.95em;outline:none}
    .search-bar .text-btn{border-radius:0 20px 20px 0;margin-left:0}

    .icons{display:flex;align-items:center}
    form.logout-form{margin:0}

    .container{max-width:1200px;margin:0 auto;padding:20px}

    /* 타이틀 */
    .result-title{font-size:1.25em;font-weight:700;margin-bottom:12px;line-height:1.3}
    .result-title .kw,.result-title .qt{color:var(--accent)}
    .result-title .count{font-weight:800}

    /* 카드형 */
    .book-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:24px}
    .book-card{position:relative;background:var(--bg-card);border:1px solid #eee;border-radius:6px;overflow:hidden;text-decoration:none;color:inherit;transition:box-shadow .2s,transform .2s;cursor:pointer}
    .book-card:hover{box-shadow:0 4px 16px var(--shadow);transform:translateY(-4px)}
    .cover{width:100%;height:240px;background-size:cover;background-position:center}
    .book-info{padding:12px}
    .book-title{font-size:.95em;font-weight:600;margin:0 0 4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .book-author{font-size:.85em;color:var(--text-gray);margin:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .overlay{position:absolute;inset:0;background:rgba(0,0,0,.4);display:flex;align-items:center;justify-content:center;opacity:0;transition:opacity .3s}
    .book-card:hover .overlay{opacity:1}
    .overlay-text{padding:8px 16px;background:#fff;border-radius:4px;font-size:.9em;font-weight:600;color:var(--primary)}

    /* 리스트형 */
    .book-list{display:flex;flex-direction:column;gap:16px}
    .book-row{display:grid;grid-template-columns:120px 1fr 140px;gap:16px;align-items:center;background:#fff;border:1px solid #eee;border-radius:10px;padding:12px;text-decoration:none;color:inherit}
    .row-cover{width:120px;height:160px;background:#f2f2f2;background-size:cover;background-position:center;border-radius:6px}
  .row-title {color: #000;}

.row-title a:hover { color: #333; }
    .row-author{color:#666;margin:0 0 8px}
    .row-desc{color:#555;font-size:.95em;line-height:1.4;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
    .row-right{justify-self:end;text-align:right;display:flex;flex-direction:column;gap:8px;align-items:flex-end}
    .row-price{font-weight:700;margin-bottom:4px}

    /* 페이지네이션 */
    .pagination{display:flex;justify-content:center;gap:6px;margin:28px 0 8px}
    .pagination a,.pagination span{padding:7px 11px;border:1px solid #e6e6ea;border-radius:10px;background:#fff;font-size:14px;text-decoration:none;color:#222}
    .pagination .active{background:#222;color:#fff;border-color:#222}
    .pagination .disabled{opacity:.5;pointer-events:none}

    @media(max-width:600px){
      .search-bar{flex-direction:column;gap:6px}
      .search-bar input,.search-bar .text-btn{width:100%;border-radius:8px}
      .book-grid{grid-template-columns:repeat(2,1fr)}
      .book-row{grid-template-columns:90px 1fr}
      .row-cover{width:90px;height:120px}
      .row-right{justify-self:start;align-items:flex-start}
    }

       /* 자동완성 제거: 항상 숨김 */
    #suggestPanel { display: none !important; }

    /* 토스트 (은은한 보라색) */
    #toast{position:fixed;top:20px;right:20px;background:#7e57c2;color:#fff;padding:10px 16px;border-radius:8px;display:none;z-index:2000;box-shadow:0 6px 20px rgba(0,0,0,.15)}
  </style>
</head>
<body>

  <!-- 공용 URL -->
  <c:url var="booksUrl"    value="/bookstore/books"/>
  <c:url var="cartUrl"     value="/bookstore/cart"/>
  <c:url var="loginUrl"    value="/loginForm"/>
  <c:url var="registerUrl" value="/register"/>
  <c:url var="mypageUrl"   value="/mypage"/>
  <c:url var="logoutUrl"   value="/logout"/>
  <c:url var="noimg" value="/resources/images/defaultcover.png"/>

  <header>
    <div class="logo"><a href="${booksUrl}">BookMarket</a></div>

    <!-- 검색폼: 검색 제출 시 list로 보이게 -->
    <form class="search-bar" action="${booksUrl}" method="get" id="searchForm">
      <input id="searchInput" type="text" name="keyword" placeholder="검색어 입력"
             value="${fn:escapeXml(keyword)}" autocomplete="off"/>
      <input type="hidden" name="size" value="${size}"/>
      <input type="hidden" name="view" value="list"/>
      <input type="hidden" name="page" value="1"/>
      <button type="submit" class="text-btn" title="검색">검색</button>
      <div id="suggestPanel" class="suggest hidden"></div>
    </form>

    <div class="icons">
      <c:choose>
        <c:when test="${empty sessionScope.loginId}">
          <a href="${loginUrl}" class="text-btn" title="로그인">로그인</a>
          <a href="${registerUrl}" class="text-btn" title="회원가입">회원가입</a>
          <a href="${cartUrl}" class="text-btn" title="장바구니">장바구니</a>
        </c:when>
        <c:otherwise>
          <a href="${mypageUrl}" class="text-btn" title="내 정보">내 정보</a>
          <form class="logout-form" action="${logoutUrl}" method="post" style="display:inline;">
            <sec:csrfInput/>
            <button type="submit" class="text-btn" title="로그아웃">로그아웃</button>
          </form>
          <a href="${cartUrl}" class="text-btn" title="장바구니">장바구니</a>
        </c:otherwise>
      </c:choose>
    </div>
  </header>

  <div class="container">
    <!-- 타이틀: 검색/전체 분기 -->
    <div class="result-title">
      <c:choose>
        <c:when test="${not empty keyword}">
          <span class="qt">‘</span><span class="kw"><c:out value='${keyword}'/></span><span class="qt">’</span>
          에 대한 <span class="count"><fmt:formatNumber value='${result.total}' type='number'/></span>개의 검색 결과
        </c:when>
        <c:otherwise>
          전체 도서 목록 (<fmt:formatNumber value='${result.total}' type='number'/>권)
        </c:otherwise>
      </c:choose>
    </div>

    <!-- 결과 없음 -->
    <c:if test="${empty books}">
      <p>결과가 없습니다.</p>
    </c:if>

    <!-- view=list 이면 리스트, 아니면 카드 -->
    <c:choose>
      <c:when test="${view eq 'list'}">
        <div class="book-list">
          <c:forEach var="b" items="${books}">
            <c:url var="detailUrl" value="/bookstore/book/${b.bookId}"/>
            <!-- 전체를 링크로 감싸면 버튼 클릭이 막히므로: 좌측만 링크, 우측은 버튼 -->
            <div class="book-row">
              <a href="${detailUrl}" style="display:contents">
                <div class="row-cover"
                     style="background-image:url('${empty b.coverImage ? noimg : b.coverImage}');"></div>
                <div>
                  <h3 class="row-title"><c:out value="${b.title}"/></h3>
                  <div class="row-author"><c:out value="${b.author}"/></div>
                  <div class="row-desc"><c:out value="${b.description}"/></div>
                </div>
              </a>
              <div class="row-right">
                <div class="row-price"><fmt:formatNumber value='${b.price}' type='number'/>원</div>

                <!-- 장바구니: 1개만 추가 + 보라 토스트 -->
                <button type="button" class="text-btn"
                        onclick="return addToCartStay(${b.bookId}, event)"
                        aria-label="장바구니 담기">장바구니</button>

                <!-- 바로구매: GET으로 결제창 (1개) -->
                <form method="get"
                      action="${pageContext.request.contextPath}/bookstore/checkoutForm"
                      style="display:inline">
                  <input type="hidden" name="bookId" value="${b.bookId}">
                  <input type="hidden" name="qty" value="1">
                  <button type="submit" class="text-btn outline" aria-label="바로구매">바로구매</button>
                </form>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:when>
      <c:otherwise>
        <div class="book-grid">
          <c:forEach var="book" items="${books}">
            <c:url var="detailUrl" value="/bookstore/book/${book.bookId}"/>
            <a class="book-card" href="${detailUrl}" aria-label="<c:out value='${book.title}'/>">
              <div class="cover"
                   style="background-image:url('${empty book.coverImage ? noimg : book.coverImage}');"></div>
              <div class="book-info">
                <div class="book-title"><c:out value="${book.title}"/></div>
                <div class="book-author"><c:out value="${book.author}"/></div>
              </div>
            </a>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>

    <!-- 페이지네이션 -->
    <c:set var="block" value="5"/>
    <fmt:parseNumber var="currentBlock" value="${(page-1)/block}" integerOnly="true"/>
    <c:set var="startPage" value="${currentBlock*block+1}"/>
    <c:set var="endPage" value="${startPage+block-1}"/>
    <c:if test="${endPage > totalPages}">
      <c:set var="endPage" value="${totalPages}"/>
    </c:if>

    <div class="pagination">
      <!-- 처음 -->
      <c:url var="firstUrl" value="/bookstore/books">
        <c:param name="page" value="1"/>
        <c:param name="size" value="${size}"/>
        <c:param name="view" value="${view}"/>
        <c:if test="${not empty keyword}">
          <c:param name="keyword" value="${keyword}"/>
        </c:if>
      </c:url>
      <a class="${page == 1 ? 'disabled' : ''}" href="${firstUrl}">&laquo; </a>

<%--       <!-- 이전 블록 -->
      <c:url var="prevUrl" value="/bookstore/books">
        <c:param name="page" value="${startPage-1}"/>
        <c:param name="size" value="${size}"/>
        <c:param name="view" value="${view}"/>
        <c:if test="${not empty keyword}">
          <c:param name="keyword" value="${keyword}"/>
        </c:if>
      </c:url>
      <a class="${startPage == 1 ? 'disabled' : ''}" href="${prevUrl}">&lsaquo; 이전</a> --%>

      <!-- 페이지 번호 -->
      <c:forEach var="p" begin="${startPage}" end="${endPage}">
        <c:choose>
          <c:when test="${p == page}">
            <span class="active">${p}</span>
          </c:when>
          <c:otherwise>
            <c:url var="pageUrl" value="/bookstore/books">
              <c:param name="page" value="${p}"/>
              <c:param name="size" value="${size}"/>
              <c:param name="view" value="${view}"/>
              <c:if test="${not empty keyword}">
                <c:param name="keyword" value="${keyword}"/>
              </c:if>
            </c:url>
            <a href="${pageUrl}">${p}</a>
          </c:otherwise>
        </c:choose>
      </c:forEach>

<%--       <!-- 다음 블록 -->
      <c:url var="nextUrl" value="/bookstore/books">
        <c:param name="page" value="${endPage+1}"/>
        <c:param name="size" value="${size}"/>
        <c:param name="view" value="${view}"/>
        <c:if test="${not empty keyword}">
          <c:param name="keyword" value="${keyword}"/>
        </c:if>
      </c:url>
      <a class="${endPage == totalPages ? 'disabled' : ''}" href="${nextUrl}">다음 &rsaquo;</a> --%>

      <!-- 마지막 -->
      <c:url var="lastUrl" value="/bookstore/books">
        <c:param name="page" value="${totalPages}"/>
        <c:param name="size" value="${size}"/>
        <c:param name="view" value="${view}"/>
        <c:if test="${not empty keyword}">
          <c:param name="keyword" value="${keyword}"/>
        </c:if>
      </c:url>
      <a class="${page == totalPages ? 'disabled' : ''}" href="${lastUrl}"> &raquo;</a>
    </div>
  </div>

  <!-- 토스트 -->
  <div id="toast" role="status" aria-live="polite">장바구니에 추가되었습니다</div>

  <!-- 자동완성 & 장바구니 JS -->
  <script>
  (()=> {
    /* ===== 자동완성 ===== */
    const input  = document.getElementById('searchInput');
    const panel  = document.getElementById('suggestPanel');
    const form   = document.getElementById('searchForm');
    const LIMIT  = 5, MINLEN = 1;
    let items = [], idx = -1, t;

    const show = ()=> panel.classList.remove('hidden');
    const hide = ()=> { panel.classList.add('hidden'); idx = -1; };
    const clear= ()=> { panel.innerHTML=''; items=[]; idx=-1; };

    const esc = s => String(s||'').replace(/[&<>\"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'}[c]));

    const render = list => {
      clear();
      if(!list || !list.length){ hide(); return; }
      const frag = document.createDocumentFragment();
      list.forEach(b=>{
        const div = document.createElement('div');
        div.className='suggest-item';
        div.setAttribute('data-title', b.title||'');
        div.innerHTML =
          '<div class="suggest-title">' + esc(b.title) + '</div>' +
          '<div class="suggest-author">' + esc(b.author) + '</div>';
        div.addEventListener('mousedown', e=>{ e.preventDefault(); apply(b.title||''); });
        frag.appendChild(div); items.push(div);
      });
      panel.appendChild(frag); show();
    };

    const apply = title => {
      input.value = title;
      const p = form.querySelector('input[name="page"]'); if(p) p.value='1';
      form.submit();
    };

    const fetchSuggest = async q => {
      const res = await fetch('/api/books/suggest?' + new URLSearchParams({keyword:q, limit:String(LIMIT)}),
                              {headers:{'Accept':'application/json'}});
      return res.ok ? res.json() : [];
    };

    const debounce = (fn,ms)=> (...a)=>{ clearTimeout(t); t=setTimeout(()=>fn(...a),ms); };

    const onInput = debounce(async ()=>{
      const q = (input.value||'').trim();
      if(q.length < MINLEN){ hide(); return; }
      try { render(await fetchSuggest(q)); } catch(e){ console.error(e); hide(); }
    },150);

    input.addEventListener('input', onInput);
    input.addEventListener('focus', ()=> { if(items.length) show(); });
    input.addEventListener('keydown', e=>{
      if(panel.classList.contains('hidden')) return;
      if(e.key==='ArrowDown'){ e.preventDefault(); idx=(idx+1)%items.length; hl(); }
      else if(e.key==='ArrowUp'){ e.preventDefault(); idx=(idx-1+items.length)%items.length; hl(); }
      else if(e.key==='Enter' && idx>=0){ e.preventDefault(); apply(items[idx].getAttribute('data-title')||''); }
      else if(e.key==='Escape'){ hide(); }
    });
    const hl = ()=> { items.forEach(el=>el.classList.remove('active')); if(idx>=0&&items[idx]) items[idx].classList.add('active'); };

    document.addEventListener('click', e=> { if(!panel.contains(e.target) && e.target!==input) hide(); });

    /* ===== 장바구니 ===== */
    const CART_PATH='/bookstore';
    function showToast(msg){
      const t = document.getElementById('toast');
      t.textContent = msg || '장바구니에 추가되었습니다';
      t.style.display = 'block';
      setTimeout(()=> t.style.display='none', 1200);
    }
    function readCart(){
      const m = document.cookie.match(/(?:^|;\s*)cart=([^;]+)/);
      if(!m) return { i: [] };
      try { return JSON.parse(decodeURIComponent(atob(m[1]))); }
      catch(e){ try { return JSON.parse(decodeURIComponent(m[1])); } catch(e2){ return { i: [] }; } }
    }
    function writeCart(cart){
      const v = btoa(encodeURIComponent(JSON.stringify(cart)));
      const maxAge = 60*60*24*14; // 14일
      document.cookie = 'cart=; Path=/; Max-Age=0; SameSite=Lax'; // 구버전 제거
      document.cookie = 'cart=' + v + '; Path=' + CART_PATH + '; Max-Age=' + maxAge + '; SameSite=Lax';
    }
    // 1개만 추가하고 페이지 유지
    window.addToCartStay = function(id, evt){
      if(evt){ evt.stopPropagation(); evt.preventDefault(); }
      const c = readCart();
      const hit = c.i.find(x => x.id === id);
      if(hit) hit.q = 1; else c.i.push({ id, q: 1 });
      writeCart(c);
      showToast('장바구니에 추가되었습니다');
      return false;
    };
  })();
  </script>
</body>
</html>
