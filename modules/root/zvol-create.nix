{ lib, config, pkgs, ... }:
let mk = name: z: lib.nameValuePair "zvol-${lib.replaceStrings ["/" " "] ["-" "-"] name}" {
  description = "Create or grow ZFS zvol ${z.dataset}";
  wantedBy = [ "multi-user.target" ];
  serviceConfig.Type = "oneshot";
  path = [ pkgs.zfs ];
  script = ''
    if ! zfs list -H -o name ${z.dataset} >/dev/null 2>&1; then
      zfs create -V ${z.size} -b ${z.volblocksize} ${z.dataset}
    else
      zfs set volsize=${z.size} ${z.dataset}
    fi
  '';
};
in {
  options.infra.root.zvolCreate.enable = lib.mkOption { type = lib.types.bool; default = !(config.infra.vm.enable or false); description = "Whether to realize planned ZFS zvols with systemd units."; };
  config = lib.mkIf config.infra.root.zvolCreate.enable {
    systemd.services = lib.mapAttrs' mk config.infra.root.zvolPlan;
  };
}
