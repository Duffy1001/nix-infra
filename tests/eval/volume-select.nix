{ runCommand, lib }:
let
  site = import ../../site;
  volumes = site.storage.state.volumes;
  select = host: lib.filterAttrs (_: v: lib.elem host (v.movableBetween or [ ]) || (v.ownerHost or null) == host) volumes;
in assert lib.hasAttr "postgres/main" (select "app01");
   assert lib.hasAttr "postgres/main" (select "app02");
   assert !(lib.hasAttr "postgres/main" (select "desktop01"));
   assert lib.hasAttr "desktop01/root-disk" (select "desktop01");
runCommand "volume-select" { } ''
  touch $out
''
