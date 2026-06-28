{ lib, config, ... }:
let
  site = import ../../site;
  hostName = config.networking.hostName or "";
  volumes = site.storage.state.volumes or { };
  belongs = v: lib.elem hostName (v.movableBetween or [ ]) || (v.ownerHost or null) == hostName;
in {
  options.infra.state.selectedVolumes = lib.mkOption {
    type = lib.types.attrs;
    default = lib.filterAttrs (_: belongs) volumes;
    readOnly = true;
    description = "State volumes this host is eligible to attach.";
  };
}
