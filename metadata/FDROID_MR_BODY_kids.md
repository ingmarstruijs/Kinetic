## Update: Kinetic Kids 0.4.7

Package: `metadata/net.moonbaseone.kinetic.kids.yml`. Source: https://github.com/ingmarstruijs/Kinetic.

**ADD** three 0.4.7 `Builds:` blocks (171/172/173); **keep** existing 0.4.6 blocks (161/162/163). `CurrentVersion` / `CurrentVersionCode` → 0.4.7 / 173.

Commit for 0.4.7: `0962d3394643ca993196992a4e9c0e01bc5a5c6e` (annotated tag `v0.4.7` — https://github.com/ingmarstruijs/Kinetic/pull/99).

GitHub release tags: `v0.4.7-kids` / `v0.4.7-link` (Build & Sign `release` job green).

**Changes (Kids):** enrollment scan hint stays above 3-button navigation; failed enroll (missing WebDAV folder / bad QR) shows a blocking error so the confirm dialog cannot cover it.

`AutoUpdateMode: Version` / `UpdateCheckMode: Tags ^v[0-9.]+-kids$` unchanged.

Thanks @junkerderprovinz for the earlier review feedback on the companion Link app; this bump ships the Kids side of that follow-up.
