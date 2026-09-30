## Checklist

### Policy

* [x] The app complies with the [inclusion criteria](https://f-droid.org/docs/Inclusion_Policy).
* [x] The original app author has been notified (and does not oppose the inclusion). If you are not the author, please paste the link of the reply from the author.
* [x] The upstream app source code repo contains the app metadata in a [Fastlane](https://gitlab.com/snippets/1895688) or [Triple-T](https://gitlab.com/snippets/1901490) folder structure. The summary and description must be included and images, icon, and changelog should also be provided for better user experience. The `en-US` locale must be included.

Submitter is the original author. Fastlane is in upstream at `apps/link/fastlane/metadata/android/en-US/` (https://github.com/ingmarstruijs/Kinetic tag `v0.4.3`).

### Docs

* [x] Please read [the guide](https://gitlab.com/fdroid/fdroiddata/-/blob/master/CONTRIBUTING.md) first if this is your first contribution.
* [x] Please make sure your metadata follows the best practice in [our templates](https://gitlab.com/fdroid/fdroiddata/tree/master/templates).
* [x] Please read the [Build Metadata Reference](https://f-droid.org/docs/Build_Metadata_Reference/) and make sure your metadata is valid.
* [x] Please read the [Quick Start Guide](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/).

### Merge Request Setup

* [x] The title of this merge request should follow "New app: app name" format.
* [x] Please make sure your fdroiddata fork is public and your branch is not protected. See.
* [x] Please read [our Git guide](https://gitlab.com/fdroid/wiki/-/wikis/Tips-for-fdroiddata-contributors/Git-Usage) if you don't know how to rebase your branch. Don't rebase your branch if there is no conflict.
* [x] All related [fdroiddata](https://gitlab.com/fdroid/fdroiddata/issues) and [RFP issues](https://gitlab.com/fdroid/rfp/issues) have been referenced in this merge request
* [x] Please only submit one app in one MR.

No related fdroiddata/RFP issues. Companion app Kinetic Kids is submitted in a separate MR.

### Metadata

* [x] Metadata must be put in `metadata/.yml`.
* [x] Metadata must be a valid YAML file.
* [x] Metadata must use LF as line ending.
* [x] Don't add summary/description/changelog/images or anything that should be provided in upstream repo. Please check the Changes tab to make sure there is no other unrelated files added in the MR.
* [x] Releases are tagged and auto update is enabled unless there is a special reason.
* [x] There is an issue tracker and contact info of the author so that we can report bugs and contact the author.
* [x] An AuthorName must be added. It doesn't need to be the real name.
* [ ] External repos are added as git submodules instead of srclibs. You can update git submodules without opening an MR in this repo and the submodule is covered by our scanner.
* [ ] Enable [Reproducible Builds](https://f-droid.org/docs/Reproducible_Builds). We'll use your signature for improved security/reliability, also allowing users to switch between different channels. Do note that if you don't enable reproducible build then the apk will be signed with our key so you can't enable it later. If you can't enable this, please add the reasons here.
* [x] Setup abi split if the APK is large and the splitted ones can be much smaller.
* [x] Only the latest versions should be kept in the metadata before it's merged. If you update the metadata, please replace the old versions with the new ones.
* [x] Don't add any disabled versions in the metadata.
* [x] The `commit` field should be the full hash. Please don't use tag or branch in commit.

Package: `metadata/net.moonbaseone.kinetic.link.yml`. Source: https://github.com/ingmarstruijs/Kinetic. Commit: `93a7a946ff30da330142782511f0b5c65bbe5273` (annotated tag `v0.4.3`).

Special reason for auto update: `AutoUpdateMode: None` / `UpdateCheckMode: None` because this is a Melos monorepo (`subdir: apps/link`); happy to add UpdateCheckData once maintainers prefer a specific pattern.

srclibs: Flutter version is taken from upstream `.flutter-version` (`srclibs: flutter@stable` then checkout that pin), following the fdroiddata Flutter template (not a git submodule).

Reproducible Builds not enabled: Flutter + Melos monorepo (workspace packages) and native `sqlite3mc`/NDK make bit-identical APKs a deliberate follow-up. First listing uses F-Droid signing; we understand RB cannot be casually enabled later.

ABI splits: three Builds entries (`131` armeabi-v7a / `132` arm64-v8a / `133` x86_64) with `--split-per-abi`.

### Pipeline

* [x] All pipelines should pass.
* [x] All warnings and errors in the Reports tab should be fixed or explained.
* [x] F-Droid CI runners are under GitLab's FOSS program, so there's no need for you to pay for any CI time. If Gitlab starts asking for phone numbers or credit cards don't submit anything, just leave a note in the MR so we know we need to trigger the CI.

Updated metadata to **0.4.3** (`v0.4.3` / `93a7a946ff30da330142782511f0b5c65bbe5273`). Local `./tool/fdroid_build.sh link` verified.
