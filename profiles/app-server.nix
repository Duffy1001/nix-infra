{ ... }:
{
  imports = [
    ../modules/services/generic-stateful-service.nix
    ../modules/services/postgresql-state.nix
    ../modules/services/forgejo-state.nix
  ];
}
