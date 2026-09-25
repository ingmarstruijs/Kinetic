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

function render(): void {
  const onPhone = isPhoneOrigin();
  app.innerHTML = `
    <header>
      <h1>Kinetic Link Web</h1>
      <p>Browser UI for personal tasks. Vault keys stay on your phone.</p>
    </header>
    <div class="card">
      <div class="status ${online ? 'online' : 'offline'}">
        ${online ? 'Connected to phone' : 'Not connected'}
      </div>
      ${
        online
          ? ''
          : `
        <p class="hint" style="margin-top:1rem">
          ${
            onPhone
              ? 'Connecting via this phone bridge…'
              : 'GitHub Pages is HTTPS — open the <strong>HTTP URL shown on your phone</strong> (same Wi‑Fi) so the browser can use <code>ws://</code>. Or paste the QR JSON below for debugging on localhost.'
          }
        </p>
        <div style="margin-top:1rem">
          <label for="qr">Paste Link Web QR JSON</label>
          <textarea id="qr" placeholder='{"v":1,"type":"link-web",...}'></textarea>
          <div class="row">
            <button id="connect" type="button">Connect</button>
          </div>
        </div>`
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
  await client.connect(qr);
  online = true;
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
    render();
  }
}

client.onConnectionChange = (v) => {
  online = v;
  if (!v) render();
};
client.onError = (m) => {
  error = m;
  render();
};

render();

if (isPhoneOrigin()) {
  void (async () => {
    const qr = await fetchPhoneQr();
    if (qr) {
      try {
        await connectWithPayload(qr);
      } catch (e) {
        error = String(e);
        render();
      }
    }
  })();
}
