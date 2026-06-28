{ lib, ... }:
{
  options.infra.root.poolName = lib.mkOption { type = lib.types.str; default = "tank"; description = "Root state ZFS pool name."; };

  config = {
    boot.supportedFilesystems = [ "zfs" ];
    services.zfs.autoScrub.enable = true;
    boot.zfs.forceImportRoot = false;
  };
}
