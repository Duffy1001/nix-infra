{ lib, config, ... }:
{
  options.infra.root.zvolPlan = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Pure plan mapping state volumes to ZFS zvols.";
  };
}
