<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>관리자 대시보드</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>

<style>
  :root{
    --bg:#f5f7fb; --white:#fff; --muted:#7b8aa3; --text:#1f2a44;
    --line:#e7ecf3; --primary:#2563eb; --success:#13b981; --danger:#ef4444;
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--text);font:14px/1.5 system-ui,-apple-system,"Noto Sans KR",Arial}
  a{color:inherit;text-decoration:none}

  .wrap{display:flex;min-height:100vh}
  .sidebar{width:240px;background:#0f172a;color:#cbd5e1;padding:16px 10px;border-right:1px solid #0b1326}
  .brand{display:flex;align-items:center;gap:8px;color:#fff;font-weight:700;font-size:18px;padding:10px 12px}
  .menu a{display:block;padding:10px 12px;border-radius:10px;color:#cbd5e1}
  .menu a:hover,.menu a.active{background:#111c38;color:#fff}

  .main{flex:1;padding:18px}
  .title-xl{font-size:18px;font-weight:800;margin:4px 0 12px 2px}

  .cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px;margin-bottom:12px}
  .card{background:var(--white);border:1px solid var(--line);border-radius:14px;padding:14px}
  .k{font-size:12px;color:#64748b;margin-bottom:4px}
  .v{font-size:22px;font-weight:800}

  /* ✅ 그래프 그리드/사이즈 조정 */
  .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(340px,1fr));gap:16px}
  .chart-box{position:relative;width:100%;height:230px;} /* 일반 관리자 페이지 사이즈 */
  @media (max-width:640px){ .chart-box{height:200px;} }

  .btn{border:1px solid #dbe2ff;background:#fff;border-radius:8px;padding:6px 10px;cursor:pointer}
  .btn.active{background:#eef2ff}
  .muted{color:#94a3b8}
</style>
</head>
<body>
<div class="wrap">
  <!-- LEFT: 사이드바 -->
  <aside class="sidebar">
    <div class="brand">📊 Admin Dashboard</div>
    <nav class="menu">
      <a class="active" href="${pageContext.request.contextPath}/admin/dashboard">대시보드</a>
      <a href="${pageContext.request.contextPath}/admin/users">사용자 관리</a>
      <a href="${pageContext.request.contextPath}/admin/books">도서 관리</a>
      <a href="${pageContext.request.contextPath}/admin/orders">주문 관리</a>
    </nav>
  </aside>

  <!-- CENTER -->
  <main class="main">
    <div class="title-xl">요약</div>

    <!-- 상단 요약 카드 -->
    <div class="cards">
      <div class="card">
        <div class="k">총 회원 수</div>
        <div class="v"><c:out value="${stats.userCount}"/></div>
      </div>
      <div class="card">
        <div class="k">총 주문 수</div>
        <div class="v"><c:out value="${stats.orderCount}"/></div>
      </div>
      <div class="card">
        <div class="k">총 매출(결제/배송 포함)</div>
        <div class="v"><c:out value="${stats.totalSales}"/> 원</div>
      </div>
    </div>

    <!-- 그래프 3개 영역 (결제방법 추가/기본설정/성장하기 자리 활용) -->
    <div class="grid">
      <!-- 결제방법 추가 → 최근 30일 매출/주문수 -->
      <div class="card">
        <div class="title-xl" style="margin-top:0">최근 30일 매출/주문수</div>
        <div class="chart-box"><canvas id="dailySalesChart"></canvas></div>
        <div class="muted" style="margin-top:6px">상태: PAID/SHIPPED/DELIVERED만 매출로 집계</div>
      </div>

      <!-- 기본설정 → 최근 12개월 매출 -->
      <div class="card">
        <div class="title-xl" style="margin-top:0">최근 12개월 매출</div>
        <div class="chart-box"><canvas id="monthlySalesChart"></canvas></div>
      </div>

      <!-- 성장하기 → 상태 분포(주문/재고) -->
      <div class="card">
        <div class="title-xl" style="margin-top:0;display:flex;justify-content:space-between;align-items:center">
          <span>상태 분포</span>
          <div>
            <button type="button" id="btnOrderPie" class="btn active">주문 상태</button>
            <button type="button" id="btnInvPie" class="btn" style="margin-left:6px">재고 상태</button>
          </div>
        </div>
        <div class="chart-box"><canvas id="statusPieChart"></canvas></div>
      </div>
    </div>
  </main>
</div>

<!-- 서버에서 내려준 JSON (EL 그대로 출력) -->
<script>
  const DAILY    = ${dailySalesJson};
  const MONTHLY  = ${monthlySalesJson};
  const STATUS   = ${statusJson};
  const INV      = ${inventoryJson};
</script>

<script>
(function(){
  // 유틸: 최근 N일 라벨
  function lastNDays(n){
    const arr=[]; const d=new Date(); d.setHours(0,0,0,0);
    for(let i=n-1;i>=0;i--){
      const t = new Date(d.getTime() - i*24*3600*1000);
      arr.push(t.toISOString().slice(0,10)); // YYYY-MM-DD
    }
    return arr;
  }
  function mapByKey(list, keyField, valField){
    const m={};
    (list||[]).forEach(r=>{ m[r[keyField]] = Number(r[valField]||0); });
    return m;
  }

  // 1) 일별 매출/주문수 (막대+라인)
  const days  = lastNDays(30);
  const byAmt = mapByKey(DAILY, 'day', 'amount');
  const byCnt = mapByKey(DAILY, 'day', 'orderCount');
  const dAmt  = days.map(d=>byAmt[d]||0);
  const dCnt  = days.map(d=>byCnt[d]||0);

  new Chart(document.getElementById('dailySalesChart'), {
    type: 'bar',
    data: {
      labels: days,
      datasets: [
        { label: '매출(원)', data: dAmt, yAxisID:'y1' },
        { label: '주문수',   data: dCnt, type:'line', yAxisID:'y2', tension:0.3 }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false, /* ✅ 높이 CSS로 제어 */
      interaction: { mode: 'index', intersect: false },
      scales: {
        y1: { position:'left',  beginAtZero:true, ticks:{ callback:v=>Number(v).toLocaleString() } },
        y2: { position:'right', beginAtZero:true, grid:{ drawOnChartArea:false } }
      },
      plugins:{ legend:{ position:'top' } }
    }
  });

  // 2) 월별 매출 (라인)
  const months = (MONTHLY||[]).map(r=>r.month);
  const mAmt   = (MONTHLY||[]).map(r=>Number(r.amount||0));
  new Chart(document.getElementById('monthlySalesChart'), {
    type: 'line',
    data: { labels: months, datasets: [{ label:'매출(원)', data:mAmt, tension:0.3 }] },
    options: {
      responsive:true,
      maintainAspectRatio:false, /* ✅ */
      scales:{ y:{ beginAtZero:true, ticks:{ callback:v=>Number(v).toLocaleString() } } },
      plugins:{ legend:{ display:true, position:'top' } }
    }
  });

  // 3) 원형: 주문 상태 / 재고 상태 전환
  let pie;
  function drawPie(labels, data){
    const ctx = document.getElementById('statusPieChart');
    if (pie) pie.destroy();
    pie = new Chart(ctx, {
      type: 'pie',
      data: { labels, datasets: [{ data }] },
      options: { responsive:true, maintainAspectRatio:false } /* ✅ */
    });
  }
  function drawOrderPie(){
    const labels = (STATUS||[]).map(r=>r.status);
    const data   = (STATUS||[]).map(r=>Number(r.count||0));
    drawPie(labels, data);
    document.getElementById('btnOrderPie').classList.add('active');
    document.getElementById('btnInvPie').classList.remove('active');
  }
  function drawInvPie(){
    const labels = ['품절(0)','임박(1~5)','정상(6+)'];
    const data   = [ Number(INV.outOfStock||0), Number(INV.lowStock||0), Number(INV.okStock||0) ];
    drawPie(labels, data);
    document.getElementById('btnOrderPie').classList.remove('active');
    document.getElementById('btnInvPie').classList.add('active');
  }

  // 초기: 주문 상태
  drawOrderPie();
  document.getElementById('btnOrderPie').onclick = drawOrderPie;
  document.getElementById('btnInvPie').onclick   = drawInvPie;
})();
</script>
</body>
</html>
