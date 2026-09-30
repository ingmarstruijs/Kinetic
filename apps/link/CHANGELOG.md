# Changelog

All notable changes to Kinetic Link are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The `### Store` subsection under each release is the source for Fastlane /
F-Droid store notes. Run `./tool/sync_fastlane_changelogs.sh` after editing it.

## [Unreleased]

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
