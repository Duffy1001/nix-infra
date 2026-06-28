# Nix Home Infrastructure

This repository is scaffolded for an **ephemeral compute + single persistent root + remote per-service state** NixOS design.

## Architecture rule

```text
site declares state.
root realizes state and trust.
compute machines consume state over NVMe/TCP only.
services depend on mounted state.
```

## Current status

The project is in planning/scaffolding phase. The directory layout, flake outputs, placeholder modules, QEMU-first test strategy, and implementation plan are present so each layer can be filled in and tested independently.

## Design decisions

- NVMe/TCP is the only persistent-data transport.
- A single root owns storage, authorization, image serving, and the SSH certificate authority trust anchor.
- Stateful service volumes are modeled so they can move between compute machines without renaming or copying the volume.
- Desktop support is included as a compute-derived profile that can iPXE boot and attach its own persistent NVMe/TCP disk without compromising the service-state model.
- QEMU VM tests are the initial proving ground until real NVMe drive properties are known.

## Build targets

Planned flake outputs:

- `nixosConfigurations.root`
- `nixosConfigurations.app01`
- `nixosConfigurations.app02`
- `nixosConfigurations.laptop01`
- `nixosConfigurations.desktop01`
- `checks.x86_64-linux.state-contract`
- `checks.x86_64-linux.volume-select`
- `checks.x86_64-linux.zvol-plan`
- `checks.x86_64-linux.nvmet-plan`

## Planning docs

- [Implementation plan](docs/plan.md)
- [Design evaluation](docs/design-evaluation.md)
- [QEMU testing strategy](docs/qemu-testing.md)
- [SSH trust anchor](docs/ssh-trust-anchor.md)
