export type QrPayload = {
  v: number;
  type: string;
  http: string;
  ws: string;
  sid: string;
  sec: string;
  exp: number;
};

export type BridgeTask = {
  id: string;
  title: string;
  isCompleted: boolean;
  notes?: string;
  dueAt?: string;
  updatedAt: string;
};

export type BridgeMessage = {
  method: string;
  id?: string;
  params?: Record<string, unknown>;
  error?: { code: string; message: string };
};

async function hmacHex(secret: string, message: string): Promise<string> {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    enc.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const sig = await crypto.subtle.sign('HMAC', key, enc.encode(message));
  return [...new Uint8Array(sig)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function randomNonce(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(16));
  return [...bytes].map((b) => b.toString(16).padStart(2, '0')).join('');
}

export function parseQr(raw: string): QrPayload | null {
  try {
    const data = JSON.parse(raw) as QrPayload;
    if (data.v !== 1 || data.type !== 'link-web') return null;
    if (!data.ws || !data.sid || !data.sec) return null;
    return data;
  } catch {
    return null;
  }
}

export class BridgeClient {
  private ws: WebSocket | null = null;
  private pending = new Map<
    string,
    { resolve: (m: BridgeMessage) => void; reject: (e: Error) => void }
  >();
  private seq = 0;
  onConnectionChange: ((online: boolean) => void) | null = null;
  onError: ((message: string) => void) | null = null;

  get online(): boolean {
    return this.ws?.readyState === WebSocket.OPEN;
  }

  async connect(qr: QrPayload): Promise<void> {
    this.disconnect();
    await new Promise<void>((resolve, reject) => {
      const socket = new WebSocket(qr.ws);
      this.ws = socket;
      const timer = window.setTimeout(() => {
        reject(new Error('WebSocket connect timeout'));
        socket.close();
      }, 8000);
      socket.onopen = async () => {
        window.clearTimeout(timer);
        this.onConnectionChange?.(true);
        try {
          await this.hello(qr);
          resolve();
        } catch (e) {
          reject(e instanceof Error ? e : new Error(String(e)));
        }
      };
      socket.onmessage = (ev) => {
        const msg = JSON.parse(String(ev.data)) as BridgeMessage;
        if (msg.id && this.pending.has(msg.id)) {
          const p = this.pending.get(msg.id)!;
          this.pending.delete(msg.id);
          if (msg.error) {
            p.reject(new Error(`${msg.error.code}: ${msg.error.message}`));
          } else {
            p.resolve(msg);
          }
        }
      };
      socket.onclose = () => {
        this.onConnectionChange?.(false);
        for (const [, p] of this.pending) {
          p.reject(new Error('disconnected'));
        }
        this.pending.clear();
      };
      socket.onerror = () => {
        this.onError?.('WebSocket error');
        reject(new Error('WebSocket error'));
      };
    });
  }

  disconnect(): void {
    this.ws?.close();
    this.ws = null;
  }

  private request(method: string, params: Record<string, unknown> = {}) {
    return new Promise<BridgeMessage>((resolve, reject) => {
      if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
        reject(new Error('not connected'));
        return;
      }
      const id = `c-${++this.seq}`;
      this.pending.set(id, { resolve, reject });
      this.ws.send(JSON.stringify({ method, id, params }));
    });
  }

  private async hello(qr: QrPayload): Promise<void> {
    const nonce = randomNonce();
    const ts = Date.now();
    const mac = await hmacHex(qr.sec, `${qr.sid}|${nonce}|${ts}`);
    const reply = await this.request('session.hello', {
      sid: qr.sid,
      nonce,
      ts,
      mac,
    });
    if (reply.method !== 'session.ok') {
      throw new Error('hello failed');
    }
  }

  async listTasks(): Promise<BridgeTask[]> {
    const reply = await this.request('tasks.list');
    const tasks = (reply.params?.tasks as BridgeTask[]) ?? [];
    return tasks;
  }

  async createTask(title: string): Promise<BridgeTask> {
    const reply = await this.request('tasks.create', { title });
    return reply.params?.task as BridgeTask;
  }

  async completeTask(id: string): Promise<BridgeTask> {
    const reply = await this.request('tasks.complete', { id });
    return reply.params?.task as BridgeTask;
  }
}

/** True when page is served from the phone bridge (HTTP LAN). */
export function isPhoneOrigin(): boolean {
  const { protocol, hostname } = window.location;
  if (protocol !== 'http:') return false;
  if (hostname === 'localhost' || hostname === '127.0.0.1') return true;
  return /^(10\.|192\.168\.|172\.(1[6-9]|2\d|3[0-1])\.)/.test(hostname);
}

export async function fetchPhoneQr(): Promise<QrPayload | null> {
  try {
    const res = await fetch('/qr.json', { cache: 'no-store' });
    if (!res.ok) return null;
    return parseQr(await res.text());
  } catch {
    return null;
  }
}
