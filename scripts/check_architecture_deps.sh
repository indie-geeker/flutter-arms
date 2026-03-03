#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

has_violation=0

echo "Checking architecture dependency rules..."

# Rule 1: only bootstrap/module_composition.dart can import module_*.
module_imports="$(rg -n "import ['\"]package:module_" app/example/lib/src --glob '*.dart' || true)"
if [[ -n "$module_imports" ]]; then
  disallowed_module_imports="$(printf '%s\n' "$module_imports" | rg -v "app/example/lib/src/bootstrap/module_composition.dart" || true)"
  if [[ -n "$disallowed_module_imports" ]]; then
    echo "\n[Rule 1] Forbidden module_* imports outside bootstrap/module_composition.dart:"
    printf '%s\n' "$disallowed_module_imports"
    has_violation=1
  fi
fi

# Rule 2: presentation layer must not use ServiceLocator directly.
presentation_locator_usage="$(rg -n "ServiceLocator\\(" app/example/lib/src/features --glob '*.dart' | rg "/presentation/" || true)"
if [[ -n "$presentation_locator_usage" ]]; then
  echo "\n[Rule 2] Forbidden ServiceLocator usage in presentation layer:"
  printf '%s\n' "$presentation_locator_usage"
  has_violation=1
fi

# Rule 3: feature cannot import another feature's internals directly.
cross_feature_imports=""
while IFS=: read -r file line content; do
  [[ -z "$file" ]] && continue

  if [[ "$file" =~ app/example/lib/src/features/([a-zA-Z0-9_]+)/ ]]; then
    current_feature="${BASH_REMATCH[1]}"
  else
    continue
  fi

  if [[ "$content" =~ package:example/src/features/([a-zA-Z0-9_]+)/ ]]; then
    imported_feature="${BASH_REMATCH[1]}"
  else
    continue
  fi

  if [[ "$current_feature" != "$imported_feature" ]]; then
    cross_feature_imports+="$file:$line:$content"$'\n'
  fi
done < <(rg -n "package:example/src/features/[a-zA-Z0-9_]+/" app/example/lib/src/features --glob '*.dart' || true)

if [[ -n "$cross_feature_imports" ]]; then
  echo "\n[Rule 3] Forbidden cross-feature internal imports:"
  printf '%s' "$cross_feature_imports"
  has_violation=1
fi

if [[ "$has_violation" -ne 0 ]]; then
  echo "\nArchitecture dependency check failed."
  exit 1
fi

echo "Architecture dependency check passed."
