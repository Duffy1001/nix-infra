#!/usr/bin/env bash
set -euo pipefail
cmd=${1:-help}
plan=${2:-/etc/nix-infra/nvmet-plan.json}
case "$cmd" in
  serve)
    echo "state-auth skeleton serving plan $plan"
    while true; do sleep 3600; done
    ;;
  allowed)
    volume=${2:?volume required}; host=${3:?host required}; plan=${4:-/etc/nix-infra/nvmet-plan.json}
    jq -e --arg volume "$volume" --arg host "$host" '.[$volume].allowedHosts[].name == $host' "$plan" >/dev/null
    ;;
  *)
    echo "usage: state-auth serve [plan] | state-auth allowed <volume> <host> [plan]" >&2
    exit 64
    ;;
esac
