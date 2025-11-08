# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FlutterArms is a Flutter monorepo managed by Melos, designed to contain multiple Flutter packages and applications. The workspace is configured to use mise for tool version management.

## Development Environment Setup

### Tool Versions
- Flutter: 3.35.6 (managed via mise)
- Managed by `mise.toml` for reproducible development environments

### Initial Setup
```bash
# Install mise if not already installed
# mise will automatically install Flutter 3.35.6 when entering the directory

# Bootstrap the melos workspace (links local packages)
mise run melos:bootstrap

# Or directly:
dart pub global activate melos
melos bootstrap
```

## Monorepo Structure

The repository follows a Melos monorepo pattern with:
- `packages/` - Shared Flutter packages and libraries
- `app/` - Flutter applications

Both directories are configured in `melos.yaml` as workspace packages.

## Common Commands

### Melos Workspace Management
```bash
# Bootstrap workspace (get dependencies, link packages)
mise run melos:bootstrap
# or: dart run melos bootstrap

# Clean workspace (remove generated files, dependencies)
mise run melos:clean
# or: dart run melos clean

# Run a melos script
mise run melos:run <script_name>
# or: dart run melos run <script_name>
```

### Flutter Commands (per package/app)
```bash
# Get dependencies for a specific package
cd packages/<package_name>
flutter pub get

# Run tests for a specific package
cd packages/<package_name>
flutter test

# Run a specific test file
flutter test test/path/to/test_file.dart

# Analyze code
flutter analyze

# Format code
dart format .
```

### Melos Multi-Package Operations
```bash
# Run command across all packages
melos exec -- flutter test

# Run command for packages matching a filter
melos exec --scope="package_*" -- flutter test

# List all packages in workspace
melos list
```

## Architecture Notes

### Monorepo Philosophy
- Shared packages should be in `packages/` directory
- Applications consuming these packages should be in `app/` directory
- Melos handles local package linking automatically during bootstrap
- Changes to local packages are immediately reflected in dependent packages without pub re-linking

### Adding New Packages
When creating a new package or app:
1. Create the directory under `packages/` or `app/`
2. Run `melos bootstrap` to link it into the workspace
3. Reference local packages in `pubspec.yaml` without version constraints - Melos handles path overrides

### Version Management
- mise ensures consistent Flutter version (3.35.6) across all developers
- Run `mise install` if Flutter version is not automatically installed
