{ ... }:
{
  imports = [ ../../profiles/base.nix ../../profiles/ephemeral-leaf.nix ../../profiles/app-server.nix ./services.nix ];
  networking.hostName = "app01";
}
