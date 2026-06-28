{ pkgs, ... }:
let customPkgs = import ../../pkgs { inherit pkgs; };
in {
  environment.systemPackages = [ customPkgs.state-auth ];
  systemd.services.state-auth = {
    description = "State volume authorization API skeleton";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = { Type = "simple"; ExecStart = "${customPkgs.state-auth}/bin/state-auth serve /etc/nix-infra/nvmet-plan.json"; };
  };
}
