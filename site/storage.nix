{
  pools.tank = { role = "state"; };
  volumeDefaults = { pool = "tank"; fsType = "xfs"; };
  state.volumes = {
    "postgres/main" = { service = "postgresql"; size = "100G"; mountpoint = "/var/lib/postgresql"; pool = "tank"; fsType = "xfs"; movableBetween = [ "app01" "app02" ]; };
    "desktop01/root-disk" = { ownerHost = "desktop01"; service = "desktop-root"; size = "500G"; mountpoint = "/persist"; pool = "tank"; fsType = "xfs"; transport = "nvme-tcp"; };
  };
}
