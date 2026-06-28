{ runCommand, lib }:
let infraLib = import ../../lib { inherit lib; };
in assert infraLib.names.volumeName "postgres/main" == "postgres-main";
   assert infraLib.names.zvolPath "tank" "postgres/main" == "tank/postgres/main";
   assert infraLib.systemd.mountUnitFor "/var/lib/postgresql" == "var-lib-postgresql.mount";
runCommand "names" { } ''
  touch $out
''
