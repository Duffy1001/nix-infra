# QEMU Testing Strategy

Hardware properties are intentionally out of scope for the first implementation pass. Tests should create the required topology in QEMU:

- `root-vm`: persistent file-backed disk, ZFS-capable root profile, SSH CA trust tooling, authorization API package, and root planning outputs. Destructive zvol/configfs realization is disabled in the boot smoke VM until the storage integration test provisions a pool.
- `compute-vm-a` and `compute-vm-b`: represented by `app01-vm` and `app02-vm`; they boot the ephemeral leaf profile, YubiKey fixture identity, NVMe/TCP initiator units, and service mount dependencies.
- `desktop-vm`: represented by `desktop01-vm`; it exercises the desktop profile, iPXE option wiring, and a dedicated persistent NVMe/TCP disk selection.

## Bootable VM outputs

The flake exposes bootable QEMU NixOS configurations and app wrappers:

```sh
nix run .#root-vm
nix run .#app01-vm
nix run .#app02-vm
nix run .#desktop01-vm
```

The VM profile uses serial console output, root autologin, a password of `root`, user-mode networking, and no graphics so the machines can boot in CI or a terminal-only development shell.

For lower-level builds without starting QEMU, build the VM derivation directly:

```sh
nix build .#nixosConfigurations.root-vm.config.system.build.vm
nix build .#nixosConfigurations.app01-vm.config.system.build.vm
```

## Next end-to-end storage test

The first end-to-end test should prove that a PostgreSQL state volume can be attached to `app01-vm`, detached, authorized for `app02-vm`, attached there, and mounted at the same service path without changing the volume identity. That test needs a root VM variant that provisions a disposable ZFS pool and enables configfs realization under `APPLY_NVMET_CONFIGFS=1`.
