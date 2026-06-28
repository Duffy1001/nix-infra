{ runCommand, lib }:
let infraLib = import ../../lib { inherit lib; };
in assert infraLib.systemd.mountUnitFor "/persist" == "persist.mount";
   assert infraLib.systemd.mountUnitFor "/var/lib/postgresql" == "var-lib-postgresql.mount";
runCommand "service-deps" { } ''
  touch $out
''
