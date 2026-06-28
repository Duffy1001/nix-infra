{ lib, config, pkgs, ... }:
let customPkgs = import ../../pkgs { inherit pkgs; };
in {
  options.infra.root.authorizationApi.enable = lib.mkOption { type = lib.types.bool; default = !(config.infra.vm.enable or false); description = "Whether to run the state volume authorization API skeleton."; };
  config = lib.mkIf config.infra.root.authorizationApi.enable {
    environment.systemPackages = [ customPkgs.state-auth ];
    systemd.services.state-auth = {
      description = "State volume authorization API skeleton";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = { Type = "simple"; ExecStart = "${customPkgs.state-auth}/bin/state-auth serve /etc/nix-infra/nvmet-plan.json"; };
    };
  };
}
