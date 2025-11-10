#!/usr/bin/env bash
set -euo pipefail
BASE_REF="${1:-main}"
ARCH_DOC="ARCHITECTURE_AND_EXECUTION_PLAN.md"

# Ensure we have the base ref locally
if ! git rev-parse --verify "origin/${BASE_REF}" >/dev/null 2>&1; then
  git fetch origin "${BASE_REF}:${BASE_REF}" || true
fi

CHANGED_FILES=$(git diff --name-only "origin/${BASE_REF}"...HEAD)

# Helper: check if a file is changed
file_changed() {
  echo "${CHANGED_FILES}" | grep -qx "$1" 2>/dev/null
}

# Rule 1: If code/infra files are changed, require the architecture doc to also be changed.
# Exempt paths (docs-only changes):
#  - .github/**, README.md, prd.md, docs/**
NEEDS_ARCH_UPDATE=false
while IFS= read -r f; do
  # Skip empty lines
  [[ -z "$f" ]] && continue
  case "$f" in
    .github/*|README.md|prd.md|docs/*)
      continue
      ;;
    *)
      # Any other change is considered code/infra and requires arch doc update
      if [[ "$f" != "$ARCH_DOC" ]]; then
        NEEDS_ARCH_UPDATE=true
      fi
      ;;
  esac
done <<< "${CHANGED_FILES}"

if [[ "$NEEDS_ARCH_UPDATE" == true ]]; then
  if ! file_changed "$ARCH_DOC"; then
    echo "Doc Guardian: Detected code/infra changes but $ARCH_DOC was not updated."
    echo "Changed files:" && echo "$CHANGED_FILES"
    exit 1
  fi
fi

# Rule 2: If the architecture doc is changed, require a Change Log or ADR addition in the diff.
if file_changed "$ARCH_DOC"; then
  ARCH_DIFF=$(git diff "origin/${BASE_REF}"...HEAD -- "$ARCH_DOC")
  # Look for added lines that indicate either new Change Log entries (- vX.Y) or new ADRs (- ADR-XXXX)
  if echo "$ARCH_DIFF" | grep -E '^\+.*(\- v[0-9]+\.[0-9]+|ADR\-)' > /dev/null; then
    echo "Doc Guardian: Architecture doc updated with Change Log/ADR entries."
  else
    echo "Doc Guardian: $ARCH_DOC changed but no new Change Log or ADR entry detected."
    echo "Please add a new line under Section 15 (Change Log) or Section 13 (Decision Log)."
    exit 1
  fi
fi

echo "Doc Guardian: All checks passed."
