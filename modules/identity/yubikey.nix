{ lib, config, ... }:
let site = import ../../site;
in {
  options.infra.identity.yubikey = {
    expected = lib.mkOption { type = lib.types.nullOr lib.types.str; default = site.hosts.${config.networking.hostName}.identity.yubikey or null; description = "Expected YubiKey inventory id."; };
    publicKeyPath = lib.mkOption { type = lib.types.nullOr lib.types.str; default = if config.infra.identity.yubikey.expected == null then null else "${toString ../../keys/yubikeys}/${config.networking.hostName}.pub"; description = "Host YubiKey public key fixture."; };
  };
}
