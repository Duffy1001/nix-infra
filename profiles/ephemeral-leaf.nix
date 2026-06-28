{ ... }:
{
  imports = [
    ../modules/boot/ephemeral-root.nix
    ../modules/identity/yubikey.nix
    ../modules/identity/ssh-trust-anchor.nix
    ../modules/boot/ipxe.nix
    ../modules/client/auth.nix
    ../modules/client/nvme-connect.nix
    ../modules/client/fs-init.nix
    ../modules/client/mounts.nix
    ../modules/client/service-deps.nix
    ../modules/client/cleanup.nix
  ];

  infra.identity.sshTrustAnchor.enable = true;
}

