# Release Notes (Simple)

Use this format for each release:

```markdown
## vX.Y.Z - YYYY-MM-DD

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Breaking Changes
- None

### Upgrade Notes
- ...
```

Quick checklist before publishing:

- `melos run analyze`
- `melos run test`
- If this is a quality stage or pre-release hardening cycle, also run coverage:
  - `melos run test:coverage`
  - `scripts/check_coverage.sh`
