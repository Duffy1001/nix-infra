{ lib, config, ... }:
let
  infraLib = import ../../lib { inherit lib; };
  serviceMounts = config.infra.state.serviceMounts or { };
  mkDeps = service: mountpoint: {
    requires = [ (infraLib.systemd.mountUnitFor mountpoint) ];
    after = [ (infraLib.systemd.mountUnitFor mountpoint) ];
  };
in { config.systemd.services = lib.mapAttrs mkDeps serviceMounts; }
