{ lib, pkgs, modulesPath, config, ... }:
{
  imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];

  options.infra.vm = {
    enable = lib.mkEnableOption "bootable QEMU test-machine defaults";
    memorySize = lib.mkOption { type = lib.types.int; default = 1024; description = "QEMU VM memory in MiB."; };
    diskSize = lib.mkOption { type = lib.types.int; default = 4096; description = "QEMU VM disk size in MiB."; };
  };

  config = lib.mkIf config.infra.vm.enable {
    boot.isContainer = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce false;
    fileSystems."/" = lib.mkForce {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    virtualisation = {
      memorySize = config.infra.vm.memorySize;
      diskSize = config.infra.vm.diskSize;
      cores = 2;
      graphics = false;
      qemu.options = [
        "-serial" "mon:stdio"
        "-nic" "user,model=virtio-net-pci"
      ];
    };

    services.getty.autologinUser = "root";
    users.users.root.initialPassword = "root";
    services.openssh.enable = lib.mkDefault true;
    networking.firewall.enable = false;
    environment.systemPackages = [ pkgs.git pkgs.jq pkgs.nvme-cli ];
  };
}
