{ ... }:
{
  imports = [ ../../profiles/base.nix ../../profiles/storage-root.nix ./hardware.nix ./disko.nix ];
  networking.hostName = "root";
  networking.hostId = "8425e349";
}
