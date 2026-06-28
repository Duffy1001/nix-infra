{ lib, config, ... }:
let volumes = config.infra.state.selectedVolumes or { };
in {
  options.infra.state.serviceMounts = lib.mkOption {
    type = lib.types.attrs;
    default = lib.mapAttrs' (name: v: lib.nameValuePair (v.service or name) v.mountpoint) volumes;
    readOnly = true;
    description = "Service-to-mountpoint bindings selected for this host.";
  };
}
