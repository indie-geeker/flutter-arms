#!/usr/bin/env bash
# 启动 prod flavor。若存在 env/prod.json 则通过 --dart-define-from-file 注入。
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
ENV_FILE="$ROOT_DIR/env/prod.json"

ARGS=(
  -t lib/main_prod.dart
  --flavor prod
  --release
)

if [[ -f "$ENV_FILE" ]]; then
  ARGS+=(--dart-define-from-file="$ENV_FILE")
else
  echo "[run_prod] env/prod.json not found; falling back to AppEnv defaults."
fi

cd "$ROOT_DIR"
exec flutter run "${ARGS[@]}" "$@"
