#!/usr/bin/env bash
# 本地完整测试流水线：analyze + test（-r compact）。
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

echo "[test] flutter analyze"
flutter analyze

echo "[test] flutter test"
flutter test -r compact "$@"
