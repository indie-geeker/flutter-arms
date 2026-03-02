#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MIN_TOTAL_COVERAGE="${MIN_TOTAL_COVERAGE:-65}"
MIN_PACKAGE_COVERAGE="${MIN_PACKAGE_COVERAGE:-60}"
COVERAGE_EXCLUDE_REGEX="${COVERAGE_EXCLUDE_REGEX:-(\\.g\\.dart$|\\.freezed\\.dart$|\\.gr\\.dart$|\\.mocks\\.dart$|\\.config\\.dart$|/generated/|/l10n/)}"

if [[ $# -gt 0 ]]; then
  PACKAGES=("$@")
else
  PACKAGES=(
    "packages/core"
    "packages/interfaces"
    "packages/modules/module_logger"
    "packages/modules/module_storage"
    "packages/modules/module_cache"
    "packages/modules/module_network"
    "app/example"
  )
fi

total_hit=0
total_found=0
has_error=0

echo "Coverage Gate"
echo "  min total:   ${MIN_TOTAL_COVERAGE}%"
echo "  min package: ${MIN_PACKAGE_COVERAGE}%"
echo

for package_dir in "${PACKAGES[@]}"; do
  lcov_file="${ROOT_DIR}/${package_dir}/coverage/lcov.info"
  if [[ ! -f "${lcov_file}" ]]; then
    echo "::error::Missing coverage file: ${lcov_file}"
    has_error=1
    continue
  fi

  read -r hit found <<<"$(awk -v ignore="${COVERAGE_EXCLUDE_REGEX}" '
    /^SF:/ { src = substr($0, 4); skip = (src ~ ignore); next }
    /^DA:/ && !skip {
      split($0, parts, ":");
      split(parts[2], details, ",");
      found++;
      if (details[2] > 0) hit++;
    }
    END { printf "%d %d", hit + 0, found + 0 }
  ' "${lcov_file}")"

  if (( found == 0 )); then
    echo "::error::No executable lines found after exclusions: ${package_dir}"
    has_error=1
    continue
  fi

  coverage_percent="$(awk -v h="${hit}" -v f="${found}" 'BEGIN { printf "%.2f", (f ? (h / f) * 100 : 0) }')"
  echo "PKG  ${package_dir} ${coverage_percent}% (${hit}/${found})"

  if ! awk -v c="${coverage_percent}" -v m="${MIN_PACKAGE_COVERAGE}" 'BEGIN { exit !(c + 1e-9 >= m) }'; then
    echo "::error::Package coverage below threshold: ${package_dir} (${coverage_percent}% < ${MIN_PACKAGE_COVERAGE}%)"
    has_error=1
  fi

  total_hit=$((total_hit + hit))
  total_found=$((total_found + found))
done

if (( total_found == 0 )); then
  echo "::error::No executable lines found in coverage reports."
  exit 1
fi

total_percent="$(awk -v h="${total_hit}" -v f="${total_found}" 'BEGIN { printf "%.2f", (h / f) * 100 }')"
echo
echo "TOTAL ${total_percent}% (${total_hit}/${total_found})"

if ! awk -v c="${total_percent}" -v m="${MIN_TOTAL_COVERAGE}" 'BEGIN { exit !(c + 1e-9 >= m) }'; then
  echo "::error::Total coverage below threshold (${total_percent}% < ${MIN_TOTAL_COVERAGE}%)"
  has_error=1
fi

if (( has_error != 0 )); then
  exit 1
fi

echo "Coverage gate passed."
