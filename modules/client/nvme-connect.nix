{ lib, config, pkgs, ... }:
let
  site = import ../../site;
  infraLib = import ../../lib { inherit lib; };
  volumes = config.infra.state.selectedVolumes or { };
  rootAddress = site.networks.storage.rootAddress;
  port = toString infraLib.nvme.defaultPort;
  connectUnit = name: v:
    let safe = infraLib.names.volumeName name; unit = "state-connect-${safe}";
    in lib.nameValuePair unit {
      description = "Connect NVMe/TCP state volume ${name}";
      wantedBy = [ "remote-fs-pre.target" ];
      before = [ "remote-fs-pre.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig.Type = "oneshot";
      path = [ pkgs.nvme-cli ];
      script = ''
        nvme connect -t tcp -a ${rootAddress} -s ${port} -n ${infraLib.nvme.nqnFor "root" safe} || true
      '';
    };
in { config.systemd.services = lib.mapAttrs' connectUnit volumes; }
