{ lib }:
{
  defaultPort = 4420;
  nqnFor = host: volume: "nqn.2026-06.local.nix-infra:${host}:${volume}";
}
