{ ... }:
{
  imports = [ ../../profiles/base.nix ../../profiles/desktop.nix ./services.nix ];
  networking.hostName = "desktop01";
}
