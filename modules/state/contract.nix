{ lib, ... }:
let site = import ../../site;
in {
  options.infra.site = lib.mkOption {
    type = lib.types.attrs;
    default = site;
    readOnly = true;
    description = "Central site inventory and state contract.";
  };
}
