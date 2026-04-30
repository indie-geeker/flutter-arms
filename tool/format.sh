#!/usr/bin/env bash
# 统一格式化。与 CI 保持一致。
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

echo "[format] dart format ."
dart format --set-exit-if-changed .
