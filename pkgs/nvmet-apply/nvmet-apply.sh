#!/usr/bin/env bash
set -euo pipefail
plan=${1:-/etc/nix-infra/nvmet-plan.json}
if [[ ! -r "$plan" ]]; then
  echo "nvmet plan not readable: $plan" >&2
  exit 1
fi
# Safe, idempotent skeleton: validate and summarize the pure plan. Real configfs
# writes are intentionally kept behind APPLY_NVMET_CONFIGFS=1 for VM bring-up.
jq -e 'type == "object"' "$plan" >/dev/null
jq -r 'to_entries[] | "export \(.key) as \(.value.nqn) at \(.value.listen.traddr):\(.value.listen.trsvcid)"' "$plan"
if [[ "${APPLY_NVMET_CONFIGFS:-0}" != 1 ]]; then
  exit 0
fi
echo "configfs realization is not enabled in this scaffold" >&2
exit 2
