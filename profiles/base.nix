{ ... }:
{
  # Keep early scaffold configurations evaluable in CI/QEMU before real hardware
  # and bootloader details exist.
  boot.isContainer = true;
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };
  system.stateVersion = "25.05";
}
