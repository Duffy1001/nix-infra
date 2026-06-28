{ ... }:
{
  # Service-specific storage adapters intentionally avoid enabling upstream
  # services. Generic dependency wiring in modules/client/service-deps.nix keeps
  # enabled services ordered after their selected state mounts.
}
