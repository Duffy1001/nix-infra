{ lib, config, pkgs, ... }:
let customPkgs = import ../../pkgs { inherit pkgs; };
in {
  environment.etc."nix-infra/nvmet-plan.json".text = builtins.toJSON config.infra.root.nvmetPlan;
  systemd.services.nvmet-apply = {
    description = "Apply NVMe/TCP target exports";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.jq pkgs.coreutils ];
    serviceConfig.Type = "oneshot";
    script = "${customPkgs.nvmet-apply}/bin/nvmet-apply /etc/nix-infra/nvmet-plan.json";
  };
}
