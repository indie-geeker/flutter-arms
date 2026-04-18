#!/usr/bin/env bash
# 清理构建产物与 pub 缓存、删除生成文件，适合解决"怪异"编译/生成问题。
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

echo "[clean] flutter clean"
flutter clean

echo "[clean] delete generated *.g.dart / *.freezed.dart / *.gr.dart"
find lib test -type f \( -name '*.g.dart' -o -name '*.freezed.dart' -o -name '*.gr.dart' \) -delete

echo "[clean] flutter pub get"
flutter pub get

echo "[clean] 可运行 tool/gen.sh 重新生成代码。"
