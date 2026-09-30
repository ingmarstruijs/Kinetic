# Changelog

All notable changes to Kinetic Kids are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The `### Store` subsection under each release is the source for Fastlane /
F-Droid store notes. Run `./tool/sync_fastlane_changelogs.sh` after editing it.

## [Unreleased]

## [0.4.3] - 2026-09-30

### Store
Family leave/join sync hardening and XP UI polish for Kids.

### Changed
- Harden sync when leaving or joining a family.
- XP-enabled UI polish.

### Fixed
- Leave cleanup keeps local key file handling consistent with Link.

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
Goal celebration and XP overflow spaarpot until the next goal.
Demo scenario polish for goal-reached flows.

### Added
- Fastlane metadata for the first F-Droid listing.
- Goal celebration and XP overflow spaarpot until the next goal.

### Changed
- Demo scenario polish for goal-reached flows.
- Disable AGP dependency metadata in APKs for F-Droid `check apk`.

## [0.4.0] - 2026-09-28

### Store
Prepare Kinetic Kids for F-Droid submission with Fastlane metadata and polish.

### Added
- Fastlane structure and F-Droid submission kit.

### Changed
- Kids UI polish ahead of the first public listing.
