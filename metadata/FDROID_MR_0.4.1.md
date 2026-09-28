# F-Droid App inclusion — Kinetic 0.4.1

**linsui closed !50466 / !50467** (custom MR body). Re-opened with official App inclusion template:
[!50470](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/50470) (Link),
[!50471](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/50471) (Kids).

Use **only** these bodies (they are the official
[App inclusion.md](https://gitlab.com/fdroid/fdroiddata/-/raw/master/.gitlab/merge_request_templates/App%20inclusion.md)
checklist with `[x]` / `[ ]` filled, plus short notes under Metadata for the
unchecked items that require a reason):

| App | Branch | Body file | Title |
| --- | --- | --- | --- |
| Link | `new/kinetic-link-0.4.1` | [`FDROID_MR_BODY_link.md`](FDROID_MR_BODY_link.md) | `New app: Kinetic Link` |
| Kids | `new/kinetic-kids-0.4.1` | [`FDROID_MR_BODY_kids.md`](FDROID_MR_BODY_kids.md) | `New app: Kinetic Kids` |

## Create MRs (GitLab UI)

1. Open new MR from the fork branch → target `fdroid/fdroiddata` `master`:
   - Link: https://gitlab.com/ingmarstruijs/fdroiddata/-/merge_requests/new?merge_request%5Bsource_branch%5D=new%2Fkinetic-link-0.4.1&merge_request%5Btarget_project_id%5D=36528&merge_request%5Btarget_branch%5D=master
   - Kids: https://gitlab.com/ingmarstruijs/fdroiddata/-/merge_requests/new?merge_request%5Bsource_branch%5D=new%2Fkinetic-kids-0.4.1&merge_request%5Btarget_project_id%5D=36528&merge_request%5Btarget_branch%5D=master
2. Title exactly: `New app: Kinetic Link` / `New app: Kinetic Kids`
3. Description: **replace everything** with the contents of the matching
   `FDROID_MR_BODY_*.md` file (or pick template **App inclusion** in the UI and
   tick the same boxes / paste the same notes).
4. Do **not** add a custom “Summary / Build / …” section instead of the checklist.

## Unchecked items (intentional)

Left `[ ]` with reasons in the body:

- git submodules vs srclibs → Flutter via `srclibs: flutter@3.44.1`
- Reproducible Builds → Flutter/Melos + sqlite3mc; F-Droid signing for first listing
- ABI split → not for first listing

## Commit

`73c877299d2c5f0cc17fa0a93804621949d3a960` (`v0.4.1`)
