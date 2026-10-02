# Changelog

All notable changes to Kinetic Link are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The `### Store` subsection under each release is the source for Fastlane /
F-Droid store notes. Run `./tool/sync_fastlane_changelogs.sh` after editing it.

## [Unreleased]

## [0.4.4] - 2026-10-02

### Store
Family ambient popover with nudges, clearer kid reminders, and accurate offline open counts.

### Added
- Ambient strip opens a full-height kids/adults popover over tasks.
- Family nudges over WebDAV with in-app banner and local notification.
- Sent-task cancel/skip for kids and adults in the creator app.

### Changed
- Collapsed kid rows show only name + open count; XP/goals stay expanded.
- Ambient strip is a borderless soft card; chips mute on sync error.
- Kid task due times labeled as reminders (not bare day/month).

### Fixed
- Offline kids open counts stay correct via cached shared status merge.
- Ambient presence no longer looks online while the header shows sync error.

## [0.4.3] - 2026-09-30

### Store
Family hub polish: clearer leave/join, compact undo toast, and fairer load metrics.

### Changed
- Family hub refreshes the roster on open with clearer leave, join, and invite flows.
- Complete-task undo SnackBar is compact and floating.
- Ambient load metrics exclude kids-linked tasks from open counts.
- Richer tasks/notes sync debug logging.

### Fixed
- Leave family clears local key state without deleting personal `family.key.enc`.
- Short-UID notes debug no longer throws on short IDs.

## [0.4.2] - 2026-09-29

### Store
F-Droid review follow-up: extract Flutter from .flutter-version, drop YAML Description (Fastlane only), ship ABI-split APKs.

### Changed
- Extract Flutter version from `.flutter-version` in the F-Droid recipe.
- Drop YAML `Description` (store copy lives in Fastlane only).
- Ship ABI-split APKs for smaller F-Droid downloads.

## [0.4.1] - 2026-09-28

### Store
First F-Droid listing.
Category icons and smart sort in Link.

### Added
- Fastlane metadata for the first F-Droid listing.
- Category icons and smart sort on tasks.

### Changed
- Disable AGP dependency metadata in APKs for F-Droid `check apk`.

## [0.4.0] - 2026-09-28

### Store
Prepare Kinetic Link for F-Droid submission with Fastlane metadata and polish.

### Added
- Fastlane structure and F-Droid submission kit.

### Changed
- Link UI polish ahead of the first public listing.
