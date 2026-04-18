#!/usr/bin/env bash
# 一键生成：build_runner + slang 翻译。
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

echo "[gen] build_runner build --delete-conflicting-outputs"
dart run build_runner build --delete-conflicting-outputs

echo "[gen] slang"
dart run slang
