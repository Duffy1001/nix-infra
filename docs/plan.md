# Implementation Plan

## Phase 0: Tooling and evaluation baseline

- Install Nix in the development/test environment and enable `nix-command` plus `flakes` experimental features.
- Keep `nix flake check` green while the repository evolves.
- Use QEMU VMs for both root and compute hosts until physical NVMe properties are known.

## Phase 1: Pure contracts and inventory

- Define `site` schemas for hosts, identities, networks, storage pools, SSH trust, and state volumes.
- Encode NVMe/TCP as the only supported persistent-data transport.
- Model movable service volumes separately from host-owned desktop or machine-local disks.
- Implement validation assertions for volume ownership, eligible placements, mountpoint conflicts, names, sizes, and transport constraints.

## Phase 2: Root storage and export planning

- Translate declared volumes into deterministic ZFS zvol plans.
- Translate zvol plans into NVMe/TCP target exports.
- Keep planning pure and eval-testable before adding systemd/configfs realization.

## Phase 3: Root realization and trust anchor

- Add disko/ZFS pool layout for the persistent root storage node.
- Implement idempotent zvol create/grow units.
- Implement NVMe/TCP target export application.
- Add authorization API skeleton for YubiKey-backed identity-to-volume access.
- Add root-managed SSH CA distribution so all booted machines trust keys signed by root.

## Phase 4: Ephemeral compute clients

- Add tmpfs/ephemeral root profile.
- Implement YubiKey/host identity wiring.
- Connect allowed NVMe/TCP volumes, initialize filesystems only when blank, and mount state before services start.
- Ensure stateful services can move between compute hosts by changing placement/ACLs, not data layout.

## Phase 5: Desktop and network boot support

- Add desktop as a normal compute-derived profile rather than a design constraint.
- Support iPXE boot artifacts.
- Allow a desktop to attach its own persistent NVMe/TCP disk while keeping service state independently movable.

## Phase 6: Service adapters

- Add adapters for PostgreSQL, Forgejo, Prometheus, Grafana, and generic stateful services.
- Ensure adapters declare required state and systemd dependencies without embedding storage details.

## Phase 7: VM integration and recovery

- Add QEMU VM tests for root zvol creation, NVMe/TCP export, compute attach, mount ordering, service migration, and desktop persistent disk attach.
- Document recovery procedures for root pool import, zvol recovery, host identity replacement, SSH CA rotation, and service re-placement.
