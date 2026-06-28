{ runCommand, lib }:
let
  site = import ../../site;
  infraLib = import ../../lib { inherit lib; };
  defaults = site.storage.volumeDefaults;
  plan = lib.mapAttrs (name: volume:
    let pool = volume.pool or defaults.pool; in {
      dataset = infraLib.names.zvolPath pool name;
      device = "/dev/zvol/${infraLib.names.zvolPath pool name}";
      size = volume.size;
    }) site.storage.state.volumes;
in assert plan."postgres/main".dataset == "tank/postgres/main";
   assert plan."postgres/main".device == "/dev/zvol/tank/postgres/main";
   assert plan."desktop01/root-disk".size == "500G";
runCommand "zvol-plan" { } ''
  touch $out
''
