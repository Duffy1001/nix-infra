{ runCommand, lib }:
let
  site = import ../../site;
  volumes = site.storage.state.volumes;
  names = lib.attrNames volumes;
  transports = map (n: volumes.${n}.transport or "nvme-tcp") names;
in assert lib.all (t: t == "nvme-tcp") transports;
   assert lib.hasAttr "postgres/main" volumes;
   assert volumes."postgres/main".movableBetween == [ "app01" "app02" ];
runCommand "state-contract" { } ''
  touch $out
''
