{ lib, config, ... }:
{
  options.infra.root.nvmetPlan = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Pure plan mapping zvols to NVMe/TCP exports.";
  };
}
