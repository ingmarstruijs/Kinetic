# Kinetic Link Web

Browser UI for **personal tasks**, paired to Kinetic Link on your phone (WhatsApp Web style).

## What you do

1. On the **phone**: Kinetic Link → **Settings → Link Web** (leave that screen open).
2. On the **computer** (same Wi‑Fi): open the **HTTP URL** under the QR, or scan the QR.
3. Tasks appear in the browser. Vault keys never leave the phone.

**GitHub Pages** (`https://…/Kinetic/`) is only a landing page — it cannot pair by itself. Always open the phone’s `http://192.168.…` URL.

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
