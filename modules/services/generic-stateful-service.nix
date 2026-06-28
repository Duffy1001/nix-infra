{ lib, config, ... }:
let
  serviceMounts = config.infra.state.serviceMounts or { };
  mkAdapter = service: mountpoint: { inherit service mountpoint; };
in {
  options.infra.services.stateful = lib.mkOption {
    type = lib.types.attrs;
    default = lib.mapAttrs mkAdapter serviceMounts;
    readOnly = true;
    description = "Generic stateful service adapter declarations derived from selected state volumes.";
  };
}
