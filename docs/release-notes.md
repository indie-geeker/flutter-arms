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

- `melos exec --scope="core" --scope="interfaces" --scope="module_logger" --scope="module_storage" --scope="module_cache" --scope="module_network" --scope="example" -- flutter analyze`
- `melos exec --scope="core" --scope="interfaces" --scope="module_logger" --scope="module_storage" --scope="module_cache" --scope="module_network" --scope="example" -- flutter test`
- If this is a quality stage or pre-release hardening cycle, also run coverage:
  - `melos exec --scope="core" --scope="interfaces" --scope="module_logger" --scope="module_storage" --scope="module_cache" --scope="module_network" --scope="example" -- flutter test --coverage`
  - `scripts/check_coverage.sh`
