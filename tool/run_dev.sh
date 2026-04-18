#!/usr/bin/env bash
# 启动 dev flavor。若存在 env/dev.json 则通过 --dart-define-from-file 注入。
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
ENV_FILE="$ROOT_DIR/env/dev.json"

ARGS=(
  -t lib/main_dev.dart
  --flavor dev
)

if [[ -f "$ENV_FILE" ]]; then
  ARGS+=(--dart-define-from-file="$ENV_FILE")
else
  echo "[run_dev] env/dev.json not found; falling back to AppEnv defaults."
  echo "[run_dev] copy env/dev.example.json to env/dev.json to inject real values."
fi

cd "$ROOT_DIR"
exec flutter run "${ARGS[@]}" "$@"
