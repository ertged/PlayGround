#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${CAPTURE_URL:?Set CAPTURE_URL to the exact preview URL.}"
: "${CAPTURE_DIR:?Set CAPTURE_DIR to the evidence output directory.}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/runner/work/_temp/omgithub-runtime}"
CAPTURE_SCRIPT="$RUNTIME_DIR/scripts/default-capture.mjs"

run() {
  /usr/bin/time -p "$@"
}

if [[ ! "$CAPTURE_URL" =~ ^https?:// ]]; then
  echo "CAPTURE_URL must be an absolute http(s) URL." >&2
  exit 1
fi
if [[ ! -f "$CAPTURE_SCRIPT" ]]; then
  echo "Browser capture runtime is unavailable: $CAPTURE_SCRIPT" >&2
  exit 1
fi

run mkdir -p "$CAPTURE_DIR"
export CAPTURE_READY_SELECTOR="${CAPTURE_READY_SELECTOR:-#game-canvas}"
export CAPTURE_START_SELECTOR="${CAPTURE_START_SELECTOR:-#play}"
export CAPTURE_STRICT="${CAPTURE_STRICT:-1}"
run node "$CAPTURE_SCRIPT"
