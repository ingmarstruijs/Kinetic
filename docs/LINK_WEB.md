# Kinetic Link Web

Browser UI for **personal tasks**, paired to Kinetic Link on your phone (WhatsApp Web style).

## Model

- **Phone holds vault keys** and WebDAV credentials.
- Browser receives **plaintext domain objects** over a short-lived LAN session.
- No Kinetic account or cloud relay.

## Same Wi‑Fi (v1)

1. In Link: **Settings → Link Web** → keep the screen open.
2. On your computer (same Wi‑Fi), open the **HTTP URL** shown under the QR (or scan the QR with a reader that opens URLs).
3. The phone serves the SPA over HTTP and a WebSocket at `/bridge` so the browser avoids HTTPS→`ws://` mixed content.

**GitHub Pages** hosts the same static SPA for discoverability (`https://<org>.github.io/Kinetic/`). From Pages you must still open the phone HTTP URL to pair (LAN `ws://`).

## Revoke

**Revoke & stop** on the phone closes sockets and wipes the session secret. Starting again mints a new QR.

## Dev

```bash
# Protocol unit tests
cd packages/link_bridge && dart test

# SPA
cd apps/link_web && npm ci && npm run dev

# Copy production build into the Link app (phone HTTP serve)
cd apps/link_web && npm run build
# then copy dist/* → apps/link/assets/link_web/
```

CI builds the SPA on PRs and deploys to GitHub Pages on pushes to `main` (see `.github/workflows/link-web-pages.yml`).

## Protocol

See `packages/link_bridge`: QR type `link-web`, HMAC session hello, `tasks.list` / `tasks.create` / `tasks.complete`.

## Later

WebRTC under the same RPC API (reach the phone off LAN without Kinetic TURN).
