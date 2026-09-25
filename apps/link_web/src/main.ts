import {
  BridgeClient,
  BridgeTask,
  fetchPhoneQr,
  isPhoneOrigin,
  parseQr,
  QrPayload,
} from './bridge';

const app = document.querySelector<HTMLDivElement>('#app')!;
const client = new BridgeClient();

let tasks: BridgeTask[] = [];
let error = '';
let online = false;
let pairing = false;

function render(): void {
  const onPhone = isPhoneOrigin();
  app.innerHTML = `
    <header>
      <h1>Kinetic Link Web</h1>
      <p>Personal tasks in the browser. Vault keys stay on your phone.</p>
    </header>
    <aside class="experimental" role="status">
      <div class="experimental-badge">Experimental</div>
      <p>Early preview. Expect rough edges, LAN-only pairing, and breaking changes. Don’t rely on it for critical workflows yet.</p>
    </aside>
    <div class="card">
      <div class="status ${online ? 'online' : 'offline'}">
        ${
          online
            ? 'Connected to phone'
            : pairing
              ? 'Connecting…'
              : 'Not connected'
        }
      </div>
      ${
        online
          ? ''
          : onPhone
            ? phonePairingCopy()
            : pagesHowToCopy()
      }
      ${error ? `<p class="error">${escapeHtml(error)}</p>` : ''}
    </div>
    ${
      online
        ? `
      <div class="card">
        <h2 style="margin:0 0 0.5rem;font-size:1.1rem">Tasks</h2>
        <ul class="tasks">
          ${
            tasks.length === 0
              ? '<li class="hint">No open tasks</li>'
              : tasks
                  .map(
                    (t) => `
              <li>
                <input type="checkbox" data-id="${t.id}" ${t.isCompleted ? 'checked disabled' : ''} />
                <span class="title">${escapeHtml(t.title)}</span>
              </li>`,
                  )
                  .join('')
          }
        </ul>
        <div class="add-row">
          <input id="new-title" type="text" placeholder="New task" />
          <button id="add" type="button">Add</button>
        </div>
        <div class="row" style="margin-top:1rem">
          <button class="secondary" id="refresh" type="button">Refresh</button>
          <button class="secondary" id="disconnect" type="button">Disconnect</button>
        </div>
      </div>`
        : ''
    }
  `;

  document.querySelector('#connect')?.addEventListener('click', () => {
    const raw = (document.querySelector('#qr') as HTMLTextAreaElement).value;
    void connectWithRaw(raw);
  });
  document.querySelector('#disconnect')?.addEventListener('click', () => {
    client.disconnect();
    online = false;
    tasks = [];
    render();
  });
  document.querySelector('#refresh')?.addEventListener('click', () => {
    void refreshTasks();
  });
  document.querySelector('#add')?.addEventListener('click', () => {
    const input = document.querySelector('#new-title') as HTMLInputElement;
    const title = input.value.trim();
    if (!title) return;
    void (async () => {
      try {
        await client.createTask(title);
        input.value = '';
        await refreshTasks();
      } catch (e) {
        error = String(e);
        render();
      }
    })();
  });
  document.querySelectorAll('input[type=checkbox][data-id]').forEach((el) => {
    el.addEventListener('change', () => {
      const id = (el as HTMLInputElement).dataset.id!;
      void (async () => {
        try {
          await client.completeTask(id);
          await refreshTasks();
        } catch (e) {
          error = String(e);
          render();
        }
      })();
    });
  });
}

function phonePairingCopy(): string {
  return `
    <ol class="steps">
      <li>This tab was opened from your phone’s Link Web screen.</li>
      <li>Pairing happens automatically — keep the Link Web screen open on the phone.</li>
    </ol>
    <p class="hint">If nothing happens, go back to the phone, tap <strong>Copy URL</strong>, and open that address here.</p>
  `;
}

function pagesHowToCopy(): string {
  return `
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
  `;
}

function escapeHtml(s: string): string {
  return s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

async function refreshTasks(): Promise<void> {
  tasks = await client.listTasks();
  error = '';
  render();
}

async function connectWithPayload(qr: QrPayload): Promise<void> {
  error = '';
  pairing = true;
  render();
  await client.connect(qr);
  online = true;
  pairing = false;
  await refreshTasks();
}

async function connectWithRaw(raw: string): Promise<void> {
  const qr = parseQr(raw.trim());
  if (!qr) {
    error = 'Invalid QR JSON';
    render();
    return;
  }
  try {
    await connectWithPayload(qr);
  } catch (e) {
    error = String(e);
    online = false;
    pairing = false;
    render();
  }
}

client.onConnectionChange = (v) => {
  online = v;
  if (!v) {
    pairing = false;
    render();
  }
};
client.onError = (m) => {
  error = m;
  render();
};

render();

if (isPhoneOrigin()) {
  pairing = true;
  render();
  void (async () => {
    const qr = await fetchPhoneQr();
    if (qr) {
      try {
        await connectWithPayload(qr);
      } catch (e) {
        error = String(e);
        pairing = false;
        render();
      }
    } else {
      error =
        'Could not read session from the phone. Keep Settings → Link Web open and reload this page.';
      pairing = false;
      render();
    }
  })();
}
