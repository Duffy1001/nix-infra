{ lib, config, ... }:
let
  infraLib = import ../../lib { inherit lib; };
  volumes = config.infra.state.selectedVolumes or { };
  mkFs = name: v:
    let safe = infraLib.names.volumeName name;
    in lib.nameValuePair v.mountpoint {
      device = "/dev/disk/by-id/nvme-${infraLib.nvme.nqnFor "root" safe}";
      fsType = v.fsType or "xfs";
      neededForBoot = false;
      options = [ "nofail" "x-systemd.requires=state-fs-init-${safe}.service" "x-systemd.after=state-fs-init-${safe}.service" ];
    };
in { config.fileSystems = lib.mapAttrs' mkFs volumes; }
