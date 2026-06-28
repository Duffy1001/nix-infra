#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 3 ]]; then
  echo "usage: state-connect <traddr> <trsvcid> <nqn>" >&2
  exit 64
fi
exec nvme connect -t tcp -a "$1" -s "$2" -n "$3"
