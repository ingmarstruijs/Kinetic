var v=Object.defineProperty;var S=(t,e,r)=>e in t?v(t,e,{enumerable:!0,configurable:!0,writable:!0,value:r}):t[e]=r;var h=(t,e,r)=>S(t,typeof e!="symbol"?e+"":e,r);(function(){const e=document.createElement("link").relList;if(e&&e.supports&&e.supports("modulepreload"))return;for(const n of document.querySelectorAll('link[rel="modulepreload"]'))o(n);new MutationObserver(n=>{for(const s of n)if(s.type==="childList")for(const i of s.addedNodes)i.tagName==="LINK"&&i.rel==="modulepreload"&&o(i)}).observe(document,{childList:!0,subtree:!0});function r(n){const s={};return n.integrity&&(s.integrity=n.integrity),n.referrerPolicy&&(s.referrerPolicy=n.referrerPolicy),n.crossOrigin==="use-credentials"?s.credentials="include":n.crossOrigin==="anonymous"?s.credentials="omit":s.credentials="same-origin",s}function o(n){if(n.ep)return;n.ep=!0;const s=r(n);fetch(n.href,s)}})();async function E(t,e){const r=new TextEncoder,o=await crypto.subtle.importKey("raw",r.encode(t),{name:"HMAC",hash:"SHA-256"},!1,["sign"]),n=await crypto.subtle.sign("HMAC",o,r.encode(e));return[...new Uint8Array(n)].map(s=>s.toString(16).padStart(2,"0")).join("")}function L(){return[...crypto.getRandomValues(new Uint8Array(16))].map(e=>e.toString(16).padStart(2,"0")).join("")}function m(t){try{const e=JSON.parse(t);return e.v!==1||e.type!=="link-web"||!e.ws||!e.sid||!e.sec?null:e}catch{return null}}class q{constructor(){h(this,"ws",null);h(this,"pending",new Map);h(this,"seq",0);h(this,"onConnectionChange",null);h(this,"onError",null)}get online(){var e;return((e=this.ws)==null?void 0:e.readyState)===WebSocket.OPEN}async connect(e){this.disconnect(),await new Promise((r,o)=>{const n=new WebSocket(e.ws);this.ws=n;const s=window.setTimeout(()=>{o(new Error("WebSocket connect timeout")),n.close()},8e3);n.onopen=async()=>{var i;window.clearTimeout(s),(i=this.onConnectionChange)==null||i.call(this,!0);try{await this.hello(e),r()}catch(a){o(a instanceof Error?a:new Error(String(a)))}},n.onmessage=i=>{const a=JSON.parse(String(i.data));if(a.id&&this.pending.has(a.id)){const g=this.pending.get(a.id);this.pending.delete(a.id),a.error?g.reject(new Error(`${a.error.code}: ${a.error.message}`)):g.resolve(a)}},n.onclose=()=>{var i;(i=this.onConnectionChange)==null||i.call(this,!1);for(const[,a]of this.pending)a.reject(new Error("disconnected"));this.pending.clear()},n.onerror=()=>{var i;(i=this.onError)==null||i.call(this,"WebSocket error"),o(new Error("WebSocket error"))}})}disconnect(){var e;(e=this.ws)==null||e.close(),this.ws=null}request(e,r={}){return new Promise((o,n)=>{if(!this.ws||this.ws.readyState!==WebSocket.OPEN){n(new Error("not connected"));return}const s=`c-${++this.seq}`;this.pending.set(s,{resolve:o,reject:n}),this.ws.send(JSON.stringify({method:e,id:s,params:r}))})}async hello(e){const r=L(),o=Date.now(),n=await E(e.sec,`${e.sid}|${r}|${o}`);if((await this.request("session.hello",{sid:e.sid,nonce:r,ts:o,mac:n})).method!=="session.ok")throw new Error("hello failed")}async listTasks(){var o;return((o=(await this.request("tasks.list")).params)==null?void 0:o.tasks)??[]}async createTask(e){var o;return(o=(await this.request("tasks.create",{title:e})).params)==null?void 0:o.task}async completeTask(e){var o;return(o=(await this.request("tasks.complete",{id:e})).params)==null?void 0:o.task}}function k(){const{protocol:t,hostname:e}=window.location;return t!=="http:"?!1:e==="localhost"||e==="127.0.0.1"?!0:/^(10\.|192\.168\.|172\.(1[6-9]|2\d|3[0-1])\.)/.test(e)}async function C(){try{const t=await fetch("/qr.json",{cache:"no-store"});return t.ok?m(await t.text()):null}catch{return null}}const P=document.querySelector("#app"),p=new q;let y=[],l="",d=!1,u=!1;function c(){var e,r,o,n;const t=k();P.innerHTML=`
    <header>
      <h1>Kinetic Link Web</h1>
      <p>Personal tasks in the browser. Vault keys stay on your phone.</p>
    </header>
    <aside class="experimental" role="status">
      <div class="experimental-badge">Experimental</div>
      <p>Early preview. Expect rough edges, LAN-only pairing, and breaking changes. Don’t rely on it for critical workflows yet.</p>
    </aside>
    <div class="card">
      <div class="status ${d?"online":"offline"}">
        ${d?"Connected to phone":u?"Connecting…":"Not connected"}
      </div>
      ${d?"":t?T():O()}
      ${l?`<p class="error">${w(l)}</p>`:""}
    </div>
    ${d?`
      <div class="card">
        <h2 style="margin:0 0 0.5rem;font-size:1.1rem">Tasks</h2>
        <ul class="tasks">
          ${y.length===0?'<li class="hint">No open tasks</li>':y.map(s=>`
              <li>
                <input type="checkbox" data-id="${s.id}" ${s.isCompleted?"checked disabled":""} />
                <span class="title">${w(s.title)}</span>
              </li>`).join("")}
        </ul>
        <div class="add-row">
          <input id="new-title" type="text" placeholder="New task" />
          <button id="add" type="button">Add</button>
        </div>
        <div class="row" style="margin-top:1rem">
          <button class="secondary" id="refresh" type="button">Refresh</button>
          <button class="secondary" id="disconnect" type="button">Disconnect</button>
        </div>
      </div>`:""}
  `,(e=document.querySelector("#connect"))==null||e.addEventListener("click",()=>{const s=document.querySelector("#qr").value;$(s)}),(r=document.querySelector("#disconnect"))==null||r.addEventListener("click",()=>{p.disconnect(),d=!1,y=[],c()}),(o=document.querySelector("#refresh"))==null||o.addEventListener("click",()=>{f()}),(n=document.querySelector("#add"))==null||n.addEventListener("click",()=>{const s=document.querySelector("#new-title"),i=s.value.trim();i&&(async()=>{try{await p.createTask(i),s.value="",await f()}catch(a){l=String(a),c()}})()}),document.querySelectorAll("input[type=checkbox][data-id]").forEach(s=>{s.addEventListener("change",()=>{const i=s.dataset.id;(async()=>{try{await p.completeTask(i),await f()}catch(a){l=String(a),c()}})()})})}function T(){return`
    <ol class="steps">
      <li>This tab was opened from your phone’s Link Web screen.</li>
      <li>Pairing happens automatically — keep the Link Web screen open on the phone.</li>
    </ol>
    <p class="hint">If nothing happens, go back to the phone, tap <strong>Copy URL</strong>, and open that address here.</p>
  `}function O(){return`
    <p class="lead">This GitHub Pages site is only a landing page. It cannot reach your vault by itself.</p>
    <ol class="steps">
      <li>On your <strong>phone</strong>: open Kinetic Link → <strong>Settings → Link Web</strong>.</li>
      <li>Leave that screen open (phone awake, same Wi‑Fi as this computer).</li>
      <li>On <strong>this computer</strong>, open the <strong>HTTP address</strong> shown under the QR
        (or tap <strong>Copy URL</strong> on the phone and paste it in the address bar).
        It looks like <code>http://192.168.…</code>.</li>
      <li>Tasks load automatically. You can close this Pages tab.</li>
    </ol>
    <details class="advanced">
      <summary>Advanced: paste QR JSON (developers)</summary>
      <label for="qr">QR payload from the Link Web screen</label>
      <textarea id="qr" placeholder='{"v":1,"type":"link-web",...}'></textarea>
      <div class="row">
        <button id="connect" type="button">Connect</button>
      </div>
    </details>
  `}function w(t){return t.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;")}async function f(){y=await p.listTasks(),l="",c()}async function b(t){l="",u=!0,c(),await p.connect(t),d=!0,u=!1,await f()}async function $(t){const e=m(t.trim());if(!e){l="Invalid QR JSON",c();return}try{await b(e)}catch(r){l=String(r),d=!1,u=!1,c()}}p.onConnectionChange=t=>{d=t,t||(u=!1,c())};p.onError=t=>{l=t,c()};c();k()&&(u=!0,c(),(async()=>{const t=await C();if(t)try{await b(t)}catch(e){l=String(e),u=!1,c()}else l="Could not read session from the phone. Keep Settings → Link Web open and reload this page.",u=!1,c()})());
