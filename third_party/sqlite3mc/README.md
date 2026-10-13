# SQLite3 Multiple Ciphers (vendored amalgamation)

Vendored for F-Droid: `package:sqlite3` with `source: sqlite3mc` downloads
prebuilt `libsqlite3mc.so` binaries. We compile this amalgamation instead via
`hooks.user_defines.sqlite3.source: source`.

| Field | Value |
|-------|-------|
| Upstream | https://github.com/utelle/SQLite3MultipleCiphers |
| Release | [v2.6.1](https://github.com/utelle/SQLite3MultipleCiphers/releases/tag/v2.6.1) (SQLite 3.54.0) |
| Artifact | `sqlite3mc-2.6.1-sqlite-3.54.0-amalgamation.zip` |
| License | MIT (see `LICENSE`) |

Files kept from the amalgamation zip (CLI shell sources omitted):

- `sqlite3mc_amalgamation.c` / `.h`
- `sqlite3.h` / `sqlite3ext.h`
