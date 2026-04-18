#!/usr/bin/env bash
# 统一格式化。生成文件（*.g.dart / *.freezed.dart / *.gr.dart）跳过。
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

echo "[format] dart format (excluding generated files)"
dart format \
  --line-length=80 \
  lib test \
  --set-exit-if-changed
