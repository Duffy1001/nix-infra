{ ... }:
{
  imports = [ ./ephemeral-leaf.nix ];

  # Desktops are first-class repo hosts, but they do not change the core
  # compute/service-state model. They may network boot and attach a dedicated
  # persistent NVMe/TCP disk volume when desired.
  infra.boot.ipxe = {
    enable = true;
    persistentDiskMode = "nvme-tcp";
  };
}
