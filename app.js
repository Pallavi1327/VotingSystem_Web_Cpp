const API = "http://localhost:8080";

async function login() {
  const type = document.getElementById("userType").value;
  const userId = document.getElementById("userId").value.trim();
  const pass = document.getElementById("password").value.trim();
  const msg = document.getElementById("msg");

  msg.innerText = "Logging in...";

  const res = await fetch(API + "/login", {
    method: "POST",
    headers: {"Content-Type":"application/json"},
    body: JSON.stringify({type, userId, pass})
  });

  const data = await res.json();

  if (data.success) {
    localStorage.setItem("userType", type);
    localStorage.setItem("userId", userId);

    if (type === "admin") window.location.href = "admin.html";
    else window.location.href = "voter.html";
  } else {
    msg.innerText = data.message;
  }
}

async function loadCandidates() {
  const list = document.getElementById("candidateList");
  if (!list) return;

  const res = await fetch(API + "/candidates");
  const data = await res.json();

  let html = "<h3>Candidate List</h3><br>";
  data.candidates.forEach(c => {
    html += `
      <button onclick="vote(${c.id})" style="margin-top:8px;">
        Vote for ${c.name}
      </button>
    `;
  });

  list.innerHTML = html;
}

async function vote(cid) {
  const voterId = localStorage.getItem("userId");
  const msg = document.getElementById("msg");
  msg.innerText = "Submitting vote...";

  const res = await fetch(API + "/vote", {
    method: "POST",
    headers: {"Content-Type":"application/json"},
    body: JSON.stringify({voterId, candidateId: cid})
  });

  const data = await res.json();
  msg.innerText = data.message;
}

async function loadResults() {
  const box = document.getElementById("resultsBox");
  const res = await fetch(API + "/results");
  const data = await res.json();

  let html = "<h3>Vote Count</h3><br>";
  data.results.forEach(r => {
    html += `<p>${r.name} : ${r.votes} votes</p>`;
  });

  box.innerHTML = html;
}

function logout() {
  localStorage.clear();
  window.location.href = "login.html";
}

window.onload = function () {
  loadCandidates();
};
