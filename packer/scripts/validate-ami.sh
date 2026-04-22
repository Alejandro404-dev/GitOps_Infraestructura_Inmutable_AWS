#!/usr/bin/env bash
set -euo pipefail

if ! command -v goss >/dev/null 2>&1; then
  echo "goss no encontrado en PATH" >&2
  exit 1
fi

GOSS_FILE="${GOSS_FILE:-packer/goss.yaml}"
goss -g "${GOSS_FILE}" validate --format documentation
