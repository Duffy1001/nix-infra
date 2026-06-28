{ pkgs, ... }:
let
  nqn = "nqn.2026-06.local.nix-infra:root:postgres-main";
  port = "4420";
in {
  name = "nvme-tcp-state-volume";

  nodes = {
    root = { pkgs, ... }: {
      virtualisation.memorySize = 768;
      networking.firewall.allowedTCPPorts = [ 4420 ];
      environment.systemPackages = [ pkgs.coreutils pkgs.util-linux pkgs.nvme-cli ];
      boot.kernelModules = [ "configfs" "nvmet" "nvmet-tcp" ];
    };

    app01 = { pkgs, ... }: {
      virtualisation.memorySize = 768;
      environment.systemPackages = [ pkgs.coreutils pkgs.util-linux pkgs.xfsprogs pkgs.nvme-cli pkgs.netcat ];
      boot.kernelModules = [ "nvme" "nvme-tcp" ];
      systemd.tmpfiles.rules = [ "d /var/lib/postgresql 0755 root root -" ];
      systemd.services.stateful-smoke = {
        description = "Write a smoke marker to the mounted remote state volume";
        serviceConfig.Type = "oneshot";
        script = ''
          test -d /var/lib/postgresql
          echo service-ok > /var/lib/postgresql/service.txt
        '';
      };
    };
  };

  testScript = ''
    root.start()
    app01.start()
    root.wait_for_unit("multi-user.target")
    app01.wait_for_unit("multi-user.target")

    root.succeed("modprobe configfs")
    root.succeed("modprobe nvmet")
    root.succeed("modprobe nvmet-tcp")
    app01.succeed("modprobe nvme")
    app01.succeed("modprobe nvme-tcp")

    root.succeed("mkdir -p /sys/kernel/config")
    root.succeed("mountpoint -q /sys/kernel/config || mount -t configfs none /sys/kernel/config")
    root.succeed("mkdir -p /srv/nvme-state")
    root.succeed("truncate -s 128M /srv/nvme-state/postgres-main.img")
    root.succeed("losetup -f --show /srv/nvme-state/postgres-main.img > /tmp/postgres-main.loop")

    root.succeed("mkdir -p /sys/kernel/config/nvmet/subsystems/${nqn}")
    root.succeed("echo 1 > /sys/kernel/config/nvmet/subsystems/${nqn}/attr_allow_any_host")
    root.succeed("mkdir -p /sys/kernel/config/nvmet/subsystems/${nqn}/namespaces/1")
    root.succeed("sh -c 'cat /tmp/postgres-main.loop > /sys/kernel/config/nvmet/subsystems/${nqn}/namespaces/1/device_path'")
    root.succeed("echo 1 > /sys/kernel/config/nvmet/subsystems/${nqn}/namespaces/1/enable")
    root.succeed("mkdir -p /sys/kernel/config/nvmet/ports/1")
    root.succeed("echo ipv4 > /sys/kernel/config/nvmet/ports/1/addr_adrfam")
    root.succeed("echo tcp > /sys/kernel/config/nvmet/ports/1/addr_trtype")
    root.succeed("echo 0.0.0.0 > /sys/kernel/config/nvmet/ports/1/addr_traddr")
    root.succeed("echo ${port} > /sys/kernel/config/nvmet/ports/1/addr_trsvcid")
    root.succeed("ln -s /sys/kernel/config/nvmet/subsystems/${nqn} /sys/kernel/config/nvmet/ports/1/subsystems/postgres-main")

    app01.wait_until_succeeds("nc -z root ${port}")
    app01.succeed("nvme connect -t tcp -a root -s ${port} -n ${nqn}")
    app01.wait_until_succeeds("test -b /dev/nvme0n1 || test -b /dev/nvme1n1")
    app01.succeed("dev=$(readlink -f /dev/disk/by-id/nvme-nqn.2026-06.local.nix-infra:root:postgres-main || (test -b /dev/nvme0n1 && echo /dev/nvme0n1 || echo /dev/nvme1n1)); mkfs.xfs -f $dev; mount $dev /var/lib/postgresql; echo state-ok > /var/lib/postgresql/state.txt")
    app01.succeed("grep -q state-ok /var/lib/postgresql/state.txt")
    app01.succeed("systemctl start stateful-smoke.service")
    app01.succeed("grep -q service-ok /var/lib/postgresql/service.txt")
    app01.succeed("umount /var/lib/postgresql")
    app01.succeed("nvme disconnect -n ${nqn}")
  '';
}
