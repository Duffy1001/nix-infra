{ runCommand, lib }:
let
  site = import ../../site;
  infraLib = import ../../lib { inherit lib; };
  allowedHosts = volume: lib.unique ((volume.movableBetween or [ ]) ++ lib.optional (volume ? ownerHost) volume.ownerHost);
  plan = lib.mapAttrs (name: volume:
    let safe = infraLib.names.volumeName name; in {
      nqn = infraLib.nvme.nqnFor "root" safe;
      listen.traddr = site.networks.storage.rootAddress;
      allowed = allowedHosts volume;
    }) site.storage.state.volumes;
in assert plan."postgres/main".nqn == "nqn.2026-06.local.nix-infra:root:postgres-main";
   assert plan."postgres/main".listen.traddr == "10.10.0.1";
   assert plan."postgres/main".allowed == [ "app01" "app02" ];
runCommand "nvmet-plan" { } ''
  touch $out
''
