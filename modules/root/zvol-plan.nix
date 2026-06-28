{ lib, config, ... }:
let
  site = import ../../site;
  infraLib = import ../../lib { inherit lib; };
  defaults = site.storage.volumeDefaults or { };
  volumes = site.storage.state.volumes or { };
  mkPlan = name: volume:
    let pool = volume.pool or defaults.pool; in {
      inherit name pool;
      dataset = infraLib.names.zvolPath pool name;
      device = "/dev/zvol/${infraLib.names.zvolPath pool name}";
      size = volume.size;
      volblocksize = volume.volblocksize or infraLib.zfs.defaultVolblocksize;
      fsType = volume.fsType or defaults.fsType;
      mountpoint = volume.mountpoint;
      service = volume.service or null;
      ownerHost = volume.ownerHost or null;
      movableBetween = volume.movableBetween or [ ];
    };
in
{
  options.infra.root.zvolPlan = lib.mkOption {
    type = lib.types.attrs;
    default = lib.mapAttrs mkPlan volumes;
    readOnly = true;
    description = "Pure plan mapping state volumes to ZFS zvols.";
  };
}
