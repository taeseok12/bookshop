<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>장바구니</title>

<style>
  body { 
    font-family:'Noto Sans KR', sans-serif; 
    margin:0; 
    background:#fff; 
    color:#000; 
  }

  .wrap { max-width:900px; margin:40px auto; padding:0 16px; }

  .cart-header h2 { margin:0; font-weight:700; font-size:1.5rem; }

  .panel { 
    background:#fff; 
    border:1px solid #000; 
    border-radius:8px; 
    padding:16px; 
    margin-bottom:20px; 
  }

  table { width:100%; border-collapse:collapse; }
  th, td { padding:6px 0; }

  .cart-row { display:flex; align-items:center; gap:12px; border-bottom:1px solid #000; padding:8px 0; }
  .cart-row:last-child { border-bottom:0; }

  .thumb { width:64px; height:86px; background:#000; background-size:cover; background-position:center; border-radius:6px; flex-shrink:0; }
  .title { font-weight:700; }
  .meta { font-size:12px; color:#333; }
  .price { margin-left:auto; min-width:100px; text-align:right; }
  .qty { width:60px; padding:4px 6px; border:1px solid #000; border-radius:6px; text-align:center; }
  .btn-del { margin-left:8px; background:none; border:0; color:#000; cursor:pointer; }
  .btn-del:hover { color:#555; }

  /* 결제 버튼 */
  .summary { margin-top:20px; border:1px solid #000; border-radius:8px; padding:16px; }
  .sum-line { display:flex; justify-content:space-between; margin:6px 0; font-weight:600; }
  .sum-line.total { font-size:16px; font-weight:800; border-top:1px solid #000; padding-top:6px; margin-top:8px; }
  #grandTotal::after, #grandTotalCopy::after { content:'원'; margin-left:2px; }

  .btn-primary { width:100%; padding:10px 0; border:0; border-radius:6px; background:#000; color:#fff; font-weight:700; cursor:pointer; margin-top:10px; }
  .btn-primary[disabled] { opacity:.5; cursor:not-allowed; }

  .empty { text-align:center; padding:40px 0; font-size:14px; color:#333; }
</style>

<c:if test="${not empty _csrf}">
  <meta name="_csrf_header" content="${_csrf.headerName}" />
  <meta name="_csrf" content="${_csrf.token}" />
</c:if>
</head>
<body>

<div class="wrap">
  <div class="cart-header">
    <h2>장바구니</h2>
  </div>

  <div id="empty" class="panel"><div class="inner empty">장바구니가 비어 있습니다.</div></div>

  <div id="cartLayout">
    <!-- 좌측 리스트 -->
    <div class="panel">
      <div class="inner">
        <table id="cartTable">
          <tbody id="cartBody"></tbody>
        </table>
      </div>
    </div>

    <!-- 결제 버튼 패널 (장바구니 리스트 아래) -->
    <aside class="panel summary">
      <div class="sum-line"><span>상품 금액</span><strong id="grandTotal">0</strong></div>
      <div class="sum-line"><span>배송비</span><span>+ 0원</span></div>
      <div class="sum-line total"><span>결제 예정 금액</span><strong id="grandTotalCopy"></strong></div>

      <form id="goCheckoutForm" method="get" action="${pageContext.request.contextPath}/bookstore/checkoutForm">
        <button id="checkoutBtn" type="submit" class="btn-primary" disabled>결제하기</button>
      </form>
    </aside>
  </div>
</div>

<c:url var="resolveUrl" value="/bookstore/cart/resolve"/>

<script>
function readCartCookie(){
  const all = document.cookie.split(';').map(s=>s.trim()).filter(s=>s.startsWith('cart='));
  if(all.length === 0) return { i: [] };
  const raw = all[all.length - 1].slice('cart='.length);
  try { return JSON.parse(decodeURIComponent(atob(raw))); }
  catch(e){ try { return JSON.parse(decodeURIComponent(raw)); } catch(e2){ return { i: [] }; } }
}
function formatWon(n){ return (Number(n)||0).toLocaleString('ko-KR'); }
function csrfHeaders(){
  const h = document.querySelector('meta[name="_csrf_header"]')?.content;
  const t = document.querySelector('meta[name="_csrf"]')?.content;
  return (h && t) ? { [h]: t } : {};
}
function showLayout(hasItems){
  document.getElementById('cartLayout').style.display = hasItems ? 'block' : 'none';
  document.getElementById('empty').style.display      = hasItems ? 'none' : 'block';
}
function setTotalCopy(totalNumber){
  const copy = document.getElementById('grandTotalCopy');
  if (copy) copy.textContent = (Number(totalNumber)||0).toLocaleString('ko-KR') + '원';
}
async function resolveCart(){
  const payload = readCartCookie();
  const res = await fetch("${resolveUrl}", {
    method: 'POST',
    headers: Object.assign({ 'Content-Type': 'application/json' }, csrfHeaders()),
    body: JSON.stringify(payload),
    credentials: 'same-origin'
  });
  if (res.redirected) { window.location.href = res.url; return []; }
  const ct = res.headers.get('content-type') || '';
  if (!ct.includes('application/json')) throw new Error('unexpected content-type');
  if (!res.ok) {
    const err = await res.text().catch(()=> '');
    throw new Error('resolve 실패: ' + res.status + ' ' + err);
  }
  return res.json();
}

const body  = document.getElementById('cartBody');
const grand = document.getElementById('grandTotal');
const checkoutBtn = document.getElementById('checkoutBtn');

function safeCover(url){
  if (!url || typeof url !== 'string') return '';
  const u = url.trim();
  const lower = u.toLowerCase();
  if (lower.startsWith('javascript:')) return '';
  if (lower.startsWith('data:') && !lower.startsWith('data:image/')) return '';
  return u.replace(/'/g, "\\'").replace(/[\n\r]/g, '');
}

function updateCheckoutState(hasItems){
  checkoutBtn.disabled = !hasItems;
}

function render(items){
  const hasItems = Array.isArray(items) && items.length > 0;

  if (!hasItems){
    body.innerHTML = '';
    grand.textContent = '0';
    setTotalCopy(0);
    updateCheckoutState(false);
    showLayout(false);
    return;
  }

  showLayout(true);
  body.innerHTML = '';
  let total = 0;

  for (const it of items){
    const price = Number(it.price)||0;
    const qty   = Math.max(1, Number(it.qty)||1);
    const sub   = price * qty;
    total += sub;

    const tr = document.createElement('tr');
    tr.className = 'cart-row';

    tr.innerHTML =
      '<td>' +
        '<div style="display:flex; gap:12px; align-items:center;">' +
          '<div class="thumb" style="background-image:url(\'' + safeCover(it.coverImage) + '\')"></div>' +
          '<div>' +
            '<div class="title">' + (it.title ? String(it.title) : '') + '</div>' +
            '<div class="meta">재고: ' + (Number(it.stock)||0) + '</div>' +
          '</div>' +
        '</div>' +
      '</td>' +
      '<td class="price"><span class="won">' + formatWon(price) + '</span></td>' +
      '<td><input class="qty" type="number" min="1" max="' + (Number(it.stock)||1) + '" value="' + qty + '" data-id="' + Number(it.id) + '"></td>' +
      '<td><button class="btn-del" data-del="' + Number(it.id) + '">삭제</button></td>';

    body.appendChild(tr);
  }

  grand.textContent = formatWon(total);
  setTotalCopy(total);
  updateCheckoutState(true);
}

body.addEventListener('change', (e)=>{
  if (!e.target.classList.contains('qty')) return;
  const id  = Number(e.target.dataset.id);
  let qty   = Number(e.target.value || 1);
  const max = Number(e.target.getAttribute('max') || 99);
  if (qty < 1) qty = 1;
  if (qty > max) qty = max;
  e.target.value = qty;

  const c = readCartCookie();
  const list = (c.i || []).map(x => x.id === id ? ({ id, q: qty }) : x);
  const encoded = btoa(encodeURIComponent(JSON.stringify({ i: list })));
  document.cookie = 'cart=' + encoded + '; Path=/bookstore; Max-Age=' + (60*60*24*14) + '; SameSite=Lax';

  boot();
});

body.addEventListener('click', (e)=>{
  const id = e.target.getAttribute('data-del');
  if (!id) return;
  const c = readCartCookie();
  const list = (c.i || []).filter(x => x.id !== Number(id));
  const encoded = btoa(encodeURIComponent(JSON.stringify({ i: list })));
  document.cookie = 'cart=' + encoded + '; Path=/bookstore; Max-Age=' + (60*60*24*14) + '; SameSite=Lax';
  boot();
},{capture:true});

async function boot(){
  try{
    document.cookie = 'cart=; Path=/; Max-Age=0; SameSite=Lax';
    const items = await resolveCart();
    render(items);
  }catch(e){
    console.error(e);
    const empty = document.getElementById('empty');
    empty.textContent = '장바구니 로딩 오류';
    empty.style.display = 'block';
    document.getElementById('cartTable').style.display = 'none';
    checkoutBtn.disabled = true;
  }
}
boot();
</script>
</body>
</html>
