{ lib, config, ... }:
let site = import ../../site;
in {
  options.infra.client.auth = {
    hostNqnPath = lib.mkOption { type = lib.types.str; default = "${toString ../../keys/hostnqn}/${config.networking.hostName}"; description = "NVMe host NQN identity file."; };
    yubikey = lib.mkOption { type = lib.types.nullOr lib.types.str; default = site.hosts.${config.networking.hostName}.identity.yubikey or null; description = "Expected YubiKey identity for this host."; };
  };
}
