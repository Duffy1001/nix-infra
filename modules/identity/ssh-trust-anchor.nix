{ lib, config, ... }:
{
  options.infra.identity.sshTrustAnchor = {
    enable = lib.mkEnableOption "trusting the root-host SSH certificate authority";
    caPublicKeyPath = lib.mkOption {
      type = lib.types.path;
      default = ../../keys/ssh/root-ca.pub;
      description = "Public SSH CA key distributed from the root trust anchor.";
    };
  };

  config = lib.mkIf config.infra.identity.sshTrustAnchor.enable {
    services.openssh.enable = true;
    services.openssh.knownHosts.root-ca = {
      certAuthority = true;
      hostNames = [ "*" ];
      publicKeyFile = config.infra.identity.sshTrustAnchor.caPublicKeyPath;
    };
  };
}
