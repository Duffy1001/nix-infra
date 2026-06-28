{ lib, config, pkgs, ... }:
let
  infraLib = import ../../lib { inherit lib; };
  volumes = config.infra.state.selectedVolumes or { };
  mkUnit = name: v:
    let safe = infraLib.names.volumeName name; dev = "/dev/disk/by-id/nvme-${infraLib.nvme.nqnFor "root" safe}";
    in lib.nameValuePair "state-fs-init-${safe}" {
      description = "Initialize filesystem for blank state volume ${name}";
      after = [ "state-connect-${safe}.service" ];
      requires = [ "state-connect-${safe}.service" ];
      before = [ "remote-fs.target" ];
      serviceConfig.Type = "oneshot";
      path = [ pkgs.util-linux pkgs.xfsprogs pkgs.e2fsprogs ];
      script = ''
        if ! blkid ${dev} >/dev/null 2>&1; then
          case ${v.fsType or "xfs"} in
            xfs) mkfs.xfs -f ${dev} ;;
            ext4) mkfs.ext4 -F ${dev} ;;
            *) echo "unsupported fsType ${v.fsType or "xfs"}" >&2; exit 1 ;;
          esac
        fi
      '';
    };
in { config.systemd.services = lib.mapAttrs' mkUnit volumes; }
