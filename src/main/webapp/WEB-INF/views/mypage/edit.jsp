<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
:root{ --brand:#6366f1; --muted:#667085; --radius:12px; --radius-lg:14px; }

.mypage-edit .card{
  width:100%; max-width:600px; margin:12px 0 48px; padding:20px 22px;
  background:#fff; border:1px solid #e9edf5; border-radius:var(--radius-lg);
  box-shadow:0 8px 24px rgba(17,23,52,.08);
}
.mypage-edit h2.card-title{ margin:0 0 8px; font-size:20px; font-weight:700; }
.mypage-edit .fld{ margin:12px 0; }
.mypage-edit .fld label{ display:block; font-size:13px; color:var(--muted); margin-bottom:6px; }

.mypage-edit .input{
  width:100%; height:46px; padding:10px 12px; border-radius:var(--radius);
  border:1px solid #e6e8ef; background:#fff; transition:border .2s, box-shadow .2s, background .2s;
}
.mypage-edit .input:hover{ background:#fcfcfd; }
.mypage-edit .input:focus{ outline:0; border-color:var(--brand); box-shadow:0 0 0 3px rgba(99,102,241,.18); }
.mypage-edit .input:disabled{ opacity:.6; cursor:not-allowed; }
.mypage-edit .input::placeholder{ color:#9aa3b2; }

/* 에러 상태 */
.mypage-edit .input:invalid:not(:focus):not(:placeholder-shown){ border-color:#ef4444; box-shadow:none; }
.mypage-edit .fld.error .input{ border-color:#ef4444; }
.mypage-edit .fld.error .hint{ color:#ef4444; }

.mypage-edit .hint{ margin-top:6px; font-size:12px; color:var(--muted); }

.mypage-edit .btnrow{ display:flex; justify-content:flex-end; gap:8px; margin-top:16px; }
.mypage-edit .btn{
  min-height:44px; padding:10px 16px; border-radius:var(--radius);
  border:1px solid #e6e8ef; background:#fff; font-weight:600; cursor:pointer;
}
.mypage-edit .btn.primary{
  background:linear-gradient(90deg,#5965ff,#8a94ff); color:#fff; border:0;
  box-shadow:0 6px 14px rgba(99,102,241,.22);
}
.mypage-edit .btn.primary:hover{ filter:brightness(1.02); }

@media (max-width:520px){
  .mypage-edit .card{ padding:16px; border-radius:10px; }
  .mypage-edit .input{ height:44px; }
}
</style>

<section class="mypage-edit">
  <div class="card">
    <h2 class="card-title">내 정보 수정</h2>

    <!-- novalidate: 기본 브라우저 메시지 대신 커스텀 메시지 사용 -->
    <form id="editForm" method="post" action="${pageContext.request.contextPath}/bookstore/mypage/edit" novalidate>
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

      <!-- NAME: DB가 VARCHAR2(20 BYTE)라면 20바이트 제한 (한글 약 6~7자) -->
      <div class="fld" id="fld-name">
        <label for="name">이름</label>
        <input id="name" class="input" type="text" name="name"
               value="${member.name}" autocomplete="name" required
               data-max-bytes="20" maxlength="30"  <%-- UI상 문자 수 임시 상한 --%> >
        <div class="hint" id="name-hint">이름은 공백 없이 입력하세요.</div>
      </div>

      <div class="fld" id="fld-email">
        <label for="email">이메일</label>
        <input id="email" class="input" type="email" name="email"
               value="${member.email}" autocomplete="email" inputmode="email" required
               pattern="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
               oninput="this.value=this.value.toLowerCase().replace(/\s+/g,'');">
        <div class="hint" id="email-hint">계정 알림 수신 이메일로 사용됩니다.</div>
      </div>

      <div class="fld">
        <label for="hp">연락처</label>
        <input id="hp" class="input" type="tel" name="hp"
               value="${member.hp}" inputmode="tel" autocomplete="tel"
               placeholder="010-1234-5678" pattern="^0\\d{1,2}-?\\d{3,4}-?\\d{4}$">
        <div class="hint">하이픈은 자동으로 제거되어 저장됩니다.</div>
      </div>

      <div class="btnrow">
        <button type="submit" class="btn primary">저장</button>
      </div>
    </form>
  </div>
</section>

<script>
/* 공통 유틸 */
function byteLenUTF8(s){ return new TextEncoder().encode(s ?? "").length; }

/* 연락처: 숫자/하이픈만 유지 */
(function(){
  const hp = document.getElementById('hp');
  if (!hp) return;
  hp.addEventListener('input', (e)=>{
    e.target.value = e.target.value.replace(/[^\d-]/g,'').replace(/\s+/g,'');
  });
})();

/* 이름: 바이트 길이 검증(ORA-12899 방지) */
(function(){
  const name = document.getElementById('name');
  const fld = document.getElementById('fld-name');
  const hint = document.getElementById('name-hint');
  if(!name) return;

  const MAX = parseInt(name.dataset.maxBytes || '20', 10); // DB 한도 (BYTE)

  function setError(msg){
    name.setCustomValidity(msg || '');
    fld.classList.add('error');
    if(hint) hint.textContent = msg || '이름은 공백 없이 입력하세요.';
  }
  function clearError(){
    name.setCustomValidity('');
    fld.classList.remove('error');
    if(hint) hint.textContent = '이름은 공백 없이 입력하세요.';
  }
  function validateName(){
    const v = (name.value || '').trim();
    if(!v){ setError('이름을 입력하세요.'); return false; }
    const b = byteLenUTF8(v);
    if(b > MAX){
      // 한글 1자 ≈ 3바이트 기준 안내
      const approxKo = Math.floor(MAX/3);
      setError(`이름이 너무 깁니다. 최대 ${MAX}바이트(한글 약 ${approxKo}자)까지 입력 가능합니다.`);
      return false;
    }
    clearError();
    // 값 정제(양끝 공백 제거) — 서버에도 동일 로직 권장
    if(v !== name.value) name.value = v;
    return true;
  }
  name.addEventListener('input', validateName);
  name.addEventListener('blur', validateName);
})();

/* 이메일: 패턴+커스텀 메시지 */
(function(){
  const form = document.getElementById('editForm');
  const email = document.getElementById('email');
  const fld = document.getElementById('fld-email');
  const hint = document.getElementById('email-hint');
  if(!email || !form) return;

  const RE = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

  function setError(msg){
    email.setCustomValidity(msg || '');
    fld.classList.add('error');
    if(hint) hint.textContent = msg || '계정 알림 수신 이메일로 사용됩니다.';
  }
  function clearError(){
    email.setCustomValidity('');
    fld.classList.remove('error');
    if(hint) hint.textContent = '계정 알림 수신 이메일로 사용됩니다.';
  }
  function validateEmail(){
    const v = (email.value || '').trim();
    if(!v){ setError('이메일을 입력하세요.'); return false; }
    if(!RE.test(v)){ setError('이메일 형식이 올바르지 않습니다. 예: name@example.com'); return false; }
    clearError();
    if(v !== email.value) email.value = v.toLowerCase();
    return true;
  }

  email.addEventListener('input', validateEmail);
  email.addEventListener('blur', validateEmail);

  form.addEventListener('submit', function(e){
    const okName = document.getElementById('name').checkValidity(); // 커스텀 validity 반영됨
    const okEmail = validateEmail();
    if(!(okName && okEmail)){
      e.preventDefault();
      (!okName ? document.getElementById('name') : email).focus();
    }
  });
})();
</script>