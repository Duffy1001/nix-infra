{ lib, ... }:
{
  options.infra.boot.ipxe = {
    enable = lib.mkEnableOption "iPXE boot artifact integration";
    persistentDiskMode = lib.mkOption {
      type = lib.types.enum [ "none" "nvme-tcp" ];
      default = "none";
      description = "How a host receives persistent disk state after network boot.";
    };
  };
}
