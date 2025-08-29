<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="card">
  <h2>프로필</h2>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:12px">
    <div><div class="muted">아이디</div><div><strong>${member.loginId}</strong></div></div>
    <div><div class="muted">이름</div><div><strong>${member.name}</strong></div></div>
    <div><div class="muted">이메일</div><div><strong>${member.email}</strong></div></div>
    <div><div class="muted">연락처</div><div><strong>${member.hp}</strong></div></div>
  </div>
  <div style="margin-top:16px;display:flex;gap:8px">

  </div>
</div>