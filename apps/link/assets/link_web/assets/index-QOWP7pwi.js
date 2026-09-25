var k=Object.defineProperty;var S=(t,e,s)=>e in t?k(t,e,{enumerable:!0,configurable:!0,writable:!0,value:s}):t[e]=s;var p=(t,e,s)=>S(t,typeof e!="symbol"?e+"":e,s);(function(){const e=document.createElement("link").relList;if(e&&e.supports&&e.supports("modulepreload"))return;for(const n of document.querySelectorAll('link[rel="modulepreload"]'))o(n);new MutationObserver(n=>{for(const r of n)if(r.type==="childList")for(const i of r.addedNodes)i.tagName==="LINK"&&i.rel==="modulepreload"&&o(i)}).observe(document,{childList:!0,subtree:!0});function s(n){const r={};return n.integrity&&(r.integrity=n.integrity),n.referrerPolicy&&(r.referrerPolicy=n.referrerPolicy),n.crossOrigin==="use-credentials"?r.credentials="include":n.crossOrigin==="anonymous"?r.credentials="omit":r.credentials="same-origin",r}function o(n){if(n.ep)return;n.ep=!0;const r=s(n);fetch(n.href,r)}})();async function v(t,e){const s=new TextEncoder,o=await crypto.subtle.importKey("raw",s.encode(t),{name:"HMAC",hash:"SHA-256"},!1,["sign"]),n=await crypto.subtle.sign("HMAC",o,s.encode(e));return[...new Uint8Array(n)].map(r=>r.toString(16).padStart(2,"0")).join("")}function E(){return[...crypto.getRandomValues(new Uint8Array(16))].map(e=>e.toString(16).padStart(2,"0")).join("")}function m(t){try{const e=JSON.parse(t);return e.v!==1||e.type!=="link-web"||!e.ws||!e.sid||!e.sec?null:e}catch{return null}}class q{constructor(){p(this,"ws",null);p(this,"pending",new Map);p(this,"seq",0);p(this,"onConnectionChange",null);p(this,"onError",null)}get online(){var e;return((e=this.ws)==null?void 0:e.readyState)===WebSocket.OPEN}async connect(e){this.disconnect(),await new Promise((s,o)=>{const n=new WebSocket(e.ws);this.ws=n;const r=window.setTimeout(()=>{o(new Error("WebSocket connect timeout")),n.close()},8e3);n.onopen=async()=>{var i;window.clearTimeout(r),(i=this.onConnectionChange)==null||i.call(this,!0);try{await this.hello(e),s()}catch(c){o(c instanceof Error?c:new Error(String(c)))}},n.onmessage=i=>{const c=JSON.parse(String(i.data));if(c.id&&this.pending.has(c.id)){const f=this.pending.get(c.id);this.pending.delete(c.id),c.error?f.reject(new Error(`${c.error.code}: ${c.error.message}`)):f.resolve(c)}},n.onclose=()=>{var i;(i=this.onConnectionChange)==null||i.call(this,!1);for(const[,c]of this.pending)c.reject(new Error("disconnected"));this.pending.clear()},n.onerror=()=>{var i;(i=this.onError)==null||i.call(this,"WebSocket error"),o(new Error("WebSocket error"))}})}disconnect(){var e;(e=this.ws)==null||e.close(),this.ws=null}request(e,s={}){return new Promise((o,n)=>{if(!this.ws||this.ws.readyState!==WebSocket.OPEN){n(new Error("not connected"));return}const r=`c-${++this.seq}`;this.pending.set(r,{resolve:o,reject:n}),this.ws.send(JSON.stringify({method:e,id:r,params:s}))})}async hello(e){const s=E(),o=Date.now(),n=await v(e.sec,`${e.sid}|${s}|${o}`);if((await this.request("session.hello",{sid:e.sid,nonce:s,ts:o,mac:n})).method!=="session.ok")throw new Error("hello failed")}async listTasks(){var o;return((o=(await this.request("tasks.list")).params)==null?void 0:o.tasks)??[]}async createTask(e){var o;return(o=(await this.request("tasks.create",{title:e})).params)==null?void 0:o.task}async completeTask(e){var o;return(o=(await this.request("tasks.complete",{id:e})).params)==null?void 0:o.task}}function g(){const{protocol:t,hostname:e}=window.location;return t!=="http:"?!1:e==="localhost"||e==="127.0.0.1"?!0:/^(10\.|192\.168\.|172\.(1[6-9]|2\d|3[0-1])\.)/.test(e)}async function $(){try{const t=await fetch("/qr.json",{cache:"no-store"});return t.ok?m(await t.text()):null}catch{return null}}const O=document.querySelector("#app"),u=new q;let h=[],a="",d=!1;function l(){var e,s,o,n;const t=g();O.innerHTML=`
    <header>
      <h1>Kinetic Link Web</h1>
      <p>Browser UI for personal tasks. Vault keys stay on your phone.</p>
    </header>
    <div class="card">
      <div class="status ${d?"online":"offline"}">
        ${d?"Connected to phone":"Not connected"}
      </div>
      ${d?"":`
        <p class="hint" style="margin-top:1rem">
          ${t?"Connecting via this phone bridge…":"GitHub Pages is HTTPS — open the <strong>HTTP URL shown on your phone</strong> (same Wi‑Fi) so the browser can use <code>ws://</code>. Or paste the QR JSON below for debugging on localhost."}
        </p>
        <div style="margin-top:1rem">
          <label for="qr">Paste Link Web QR JSON</label>
          <textarea id="qr" placeholder='{"v":1,"type":"link-web",...}'></textarea>
          <div class="row">
            <button id="connect" type="button">Connect</button>
          </div>
        </div>`}
      ${a?`<p class="error">${w(a)}</p>`:""}
    </div>
    ${d?`
      <div class="card">
        <h2 style="margin:0 0 0.5rem;font-size:1.1rem">Tasks</h2>
        <ul class="tasks">
          ${h.length===0?'<li class="hint">No open tasks</li>':h.map(r=>`
              <li>
                <input type="checkbox" data-id="${r.id}" ${r.isCompleted?"checked disabled":""} />
                <span class="title">${w(r.title)}</span>
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
  `,(e=document.querySelector("#connect"))==null||e.addEventListener("click",()=>{const r=document.querySelector("#qr").value;P(r)}),(s=document.querySelector("#disconnect"))==null||s.addEventListener("click",()=>{u.disconnect(),d=!1,h=[],l()}),(o=document.querySelector("#refresh"))==null||o.addEventListener("click",()=>{y()}),(n=document.querySelector("#add"))==null||n.addEventListener("click",()=>{const r=document.querySelector("#new-title"),i=r.value.trim();i&&(async()=>{try{await u.createTask(i),r.value="",await y()}catch(c){a=String(c),l()}})()}),document.querySelectorAll("input[type=checkbox][data-id]").forEach(r=>{r.addEventListener("change",()=>{const i=r.dataset.id;(async()=>{try{await u.completeTask(i),await y()}catch(c){a=String(c),l()}})()})})}function w(t){return t.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;")}async function y(){h=await u.listTasks(),a="",l()}async function b(t){a="",await u.connect(t),d=!0,await y()}async function P(t){const e=m(t.trim());if(!e){a="Invalid QR JSON",l();return}try{await b(e)}catch(s){a=String(s),d=!1,l()}}u.onConnectionChange=t=>{d=t,t||l()};u.onError=t=>{a=t,l()};l();g()&&(async()=>{const t=await $();if(t)try{await b(t)}catch(e){a=String(e),l()}})();
