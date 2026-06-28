# QEMU Testing Strategy

Hardware properties are intentionally out of scope for the first implementation pass. Tests should create the required topology in QEMU:

- `root-vm`: ephemeral tmpfs disk, ZFS-capable root profile, SSH CA trust tooling, authorization API package, and root planning outputs. Destructive zvol/configfs realization is disabled in the boot smoke VM until the storage integration test provisions a pool.
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

The VM profile uses serial console output, root autologin, a password of `root`, user-mode networking, no graphics, and an ephemeral tmpfs root so `nix run` does not leave `*.qcow2` files in the repository.

For lower-level builds without starting QEMU, build the VM derivation directly:

```sh
nix build .#nixosConfigurations.root-vm.config.system.build.vm
nix build .#nixosConfigurations.app01-vm.config.system.build.vm
```

## End-to-end NVMe/TCP state test

The flake also exposes a real two-machine NixOS VM test that starts a root target VM and an app/service VM, loads the kernel NVMe target and initiator modules, exports a loop-backed namespace through configfs over NVMe/TCP, connects to it from the app VM with `nvme connect`, formats and mounts it at `/var/lib/postgresql`, and starts a service that writes into that mounted state.

Run it on a host with KVM support enabled for Nix builds:

```sh
nix build .#checks.x86_64-linux.vm-nvme-state
```

This check requires the Nix builder features `kvm` and `nixos-test`; it will evaluate but cannot execute on builders that do not expose KVM.

## Future migration test

A follow-up test should prove that the same state volume can be detached from `app01-vm`, authorized for `app02-vm`, attached there, and mounted at the same service path without changing the volume identity.
