{ ... }:
{
  imports = [
    ../modules/root/disko-zpool.nix
    ../modules/root/zvol-plan.nix
    ../modules/root/zvol-create.nix
    ../modules/root/nvmet-plan.nix
    ../modules/root/nvmet-export.nix
    ../modules/root/authorization-api.nix
    ../modules/root/image-server.nix
  ];
}
