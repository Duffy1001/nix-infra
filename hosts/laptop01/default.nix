{ ... }:
{
  imports = [ ../../profiles/base.nix ../../profiles/laptop.nix ./services.nix ];
  networking.hostName = "laptop01";
}
