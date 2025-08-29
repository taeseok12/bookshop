<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>BookMarket · 마이페이지</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
<style>
:root {
  --brand:#5965ff; --accent:#22c55e; --danger:#ef4444; --ink:#0f172a; --muted:#667085;
  --bg:#f6f7fb; --card:#fff; --line:#e8ebf4; --radius:12px; --shadow:0 10px 30px rgba(17,23,52,.08);
  --header-h:56px;
}

/* 기본 레이아웃 */
*{box-sizing:border-box}
body{margin:0;font-family:'Noto Sans KR',sans-serif;background:var(--bg);color:var(--ink);}
a{text-decoration:none;color:inherit}

/* header */
header{
  position:sticky; top:0; height:var(--header-h); background:var(--card);
  border-bottom:1px solid var(--line);
  display:flex; align-items:center; justify-content:space-between;
  padding:0 14px;
}
.logo{
  font-weight:700; font-size:22px; color:var(--brand);
  margin-left:0; /* 왼쪽 끝 */
}

/* content */
main{padding:18px}
.container{
  max-width:900px; margin:40px auto; display:flex; flex-direction:column; gap:20px;
}
.card{
  background:var(--card); border:1px solid var(--line); border-radius:var(--radius);
  box-shadow:var(--shadow); padding:30px; width:100%;
  min-width:0;
}
h2.card-title{margin-bottom:12px;font-size:20px;font-weight:700}

/* 프로필 요약 텍스트 */
.card p{font-size:16px; line-height:1.6;}

/* 최근 주문/알림 영역 */
.card > div{
  display:flex; gap:20px; flex-wrap:wrap;
}
.card > div > div{
  flex:1; min-width:320px; padding:12px; border-radius:var(--radius); border:1px solid var(--line); background:#fbfdff;
}

/* Badge (옵션) */
.badge{
  min-width:18px; height:18px; border-radius:9px; background:#ff6b6b; color:#fff; font-size:11px;
  display:flex; align-items:center; justify-content:center; margin-left:4px;
}
</style>

</head>
<body class="sb-open"><%-- 데스크톱 첫 방문: 펼침 기본 --%>


<header>
  <a class="logo" href="${pageContext.request.contextPath}/bookstore">BookMarket</a>

  <div style="display:flex;align-items:center;gap:8px">
    <a class="icon-btn" href="${pageContext.request.contextPath}/bookstore/mypage" aria-label="내 정보" title="내 정보">프로필</a>
    <a class="icon-btn" href="${pageContext.request.contextPath}/bookstore/cart" aria-label="장바구니" title="장바구니">
      장바구니
    </a>
    <a class="icon-btn" href="${pageContext.request.contextPath}/mypage/orders" aria-label="배송중" title="배송중">
      배송현황
    </a>
  </div>
</header>


<div class="layout">

  <!-- Content -->
  <main id="main">
	<div class="container">
	  <div class="pagehead">
	    <h1>마이페이지</h1>
	  </div>
	
	  <c:choose>
	    <c:when test="${not empty pageContent}">
	      <jsp:include page="${pageContent}"/>
	    </c:when>
	    <c:otherwise>
	      <div class="card">
	        <h2 class="card-title">프로필 요약</h2>
	        <p>
	          <strong><c:out value="${member.name}"/></strong> (<c:out value="${member.loginId}"/>) ·
	          <c:out value="${member.email}"/> / 
	          <c:out value="${empty member.hp ? '연락처 없음' : member.hp}"/>
	        </p>
	        <div>
	          <div>
	            <div style="font-size:13px;color:#475569;margin-bottom:6px">최근 주문</div>
	            <div>
	              <c:choose>
	                <c:when test="${not empty lastOrder}">
	                  <c:out value="${lastOrder.summary}"/> · <c:out value="${lastOrder.status}"/> · <c:out value="${lastOrder.date}"/>
	                </c:when>
	                <c:otherwise>최근 주문이 없습니다.</c:otherwise>
	              </c:choose>
	            </div>
	          </div>
	          <div>
	            <div style="font-size:13px;color:#475569;margin-bottom:6px">알림</div>
	            <div style="background:#f6fff9;">
	              <c:out value="${empty notice ? '새 알림이 없습니다.' : notice}"/>
	            </div>
	          </div>
	        </div>
	      </div>
	    </c:otherwise>
	  </c:choose>
	</div>


      <!-- 비밀번호 페이지에 공통으로 쓰이는 보조 UI(JS가 존재하면 자동 동작) -->
      <c:if test="${pageKey=='password'}">
        <script>
          // 패스워드 보기/숨기기 + 규칙/강도 + 일치검사 + 중복제출방지(PRG 전)
          (function(){
            const $ = s => document.querySelector(s);
            const cur = $('#currentPassword') || $('[name="currentPassword"]');
            const npw = $('#newPassword') || $('[name="newPassword"]');
            const cfm = $('#confirmPassword') || $('[name="confirmPassword"]');
            const form = document.querySelector('form#pwdForm') || npw?.closest('form');

            // 보기/숨기기
            document.querySelectorAll('[data-eye-for]').forEach(btn=>{
              btn.addEventListener('click',()=>{
                const target = document.getElementById(btn.dataset.eyeFor);
                if(!target) return;
                target.type = (target.type === 'password') ? 'text' : 'password';
                btn.setAttribute('aria-pressed', target.type!=='password');
              });
            });

            // 강도 측정
            const bar = $('#pwBar'), txt = $('#pwStrengthText');
            const score = v=>{
              let s = 0;
              if(v.length >= 8) s++;
              if(/[A-Z]/.test(v) && /[a-z]/.test(v)) s++;
              if(/\d/.test(v)) s++;
              if(/[^\w\s]/.test(v)) s++;
              return s; // 0~4
            };
            const updateStrength = v=>{
              if(!bar||!txt) return;
              const s = score(v);
              bar.style.width = (s*25)+'%';
              txt.textContent = ['매우 약함','약함','보통','좋음','매우 좋음'][s];
            };
            npw?.addEventListener('input',e=>updateStrength(e.target.value));
            updateStrength(npw?.value||'');

            // 일치 체크
            const match = $('#pwMatch');
            const checkMatch = ()=> {
              if(!npw||!cfm||!match) return;
              if(!cfm.value){ match.textContent=''; match.className='match'; return;}
              const ok = (npw.value === cfm.value);
              match.textContent = ok ? '새 비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.';
              match.className = 'match ' + (ok ? 'ok' : 'bad');
            };
            npw?.addEventListener('input',checkMatch);
            cfm?.addEventListener('input',checkMatch);

            // 제출(중복방지 + 로딩)
            if(form){
              let submitting=false;
              form.addEventListener('submit', (e)=>{
                if(submitting){ e.preventDefault(); return; }
                const submitBtn = form.querySelector('button[type="submit"]');
                if(submitBtn){
                  submitting=true;
                  submitBtn.disabled=true;
                  const icon = document.createElement('span');
                  icon.className='spinner';
                  submitBtn.prepend(icon);
                }
              });
            }
          })();
        </script>
      </c:if>
    </div>
  </main>
</div>

<script>
/* 사이드바 토글 & 핀 상태 저장(데스크톱만) */
(function(){
  const body=document.body, toggle=document.getElementById('toggle'), pin=document.getElementById('pin');
  const KEY='sbPinned';
  const isDesktop = ()=>window.matchMedia('(min-width:981px)').matches;

  const applyPinned = pinned=>{
    if(isDesktop()){
      body.classList.toggle('sb-open', pinned);
      document.documentElement.style.setProperty('--sb-w', pinned ? 'var(--sb-expanded)' : 'var(--sb-collapsed)');
      pin.setAttribute('aria-pressed', pinned);
      try{ localStorage.setItem(KEY, pinned?'1':'0'); }catch(e){}
    }
  };

  // 초기화: 데스크톱 첫 방문은 펼침(기본), 저장값 있으면 반영
  const saved = (()=>{
    try{ return localStorage.getItem(KEY); }catch(e){ return null; }
  })();
  if(saved!==null) applyPinned(saved==='1'); else applyPinned(true);

  // 토글 버튼(모바일=오버레이 열기/닫기, 데스크톱=핀 토글)
  toggle.addEventListener('click', ()=>{
    if(isDesktop()){
      applyPinned(!body.classList.contains('sb-open'));
    }else{
      body.classList.toggle('sb-open');
    }
  });
  pin.addEventListener('click', ()=>applyPinned(!body.classList.contains('sb-open')));

  // 리사이즈 모드 전환 시 상태 수복
  window.addEventListener('resize', ()=>{
    if(isDesktop()){
      const v = (saved!==null ? saved==='1' : true);
      applyPinned(v);
    }else{
      // 모바일 내려오면 오버레이만 사용(기본 닫힘)
      body.classList.remove('sb-open');
    }
  });
})();
</script>
</body>
</html>