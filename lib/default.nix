{ lib }:
{
  names = import ./names.nix { inherit lib; };
  systemd = import ./systemd.nix { inherit lib; };
  zfs = import ./zfs.nix { inherit lib; };
  nvme = import ./nvme.nix { inherit lib; };
}
