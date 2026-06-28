{ ... }:
{
  systemd.services.state-disconnect = {
    description = "Disconnect NVMe/TCP state volumes during shutdown";
    wantedBy = [ "shutdown.target" ];
    before = [ "shutdown.target" ];
    serviceConfig.Type = "oneshot";
    script = "/run/current-system/sw/bin/nvme disconnect-all || true";
  };
}
