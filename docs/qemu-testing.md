# QEMU Testing Strategy

Hardware properties are intentionally out of scope for the first implementation pass. Tests should create the required topology in QEMU:

- `root-vm`: persistent file-backed disk, ZFS pool, NVMe/TCP target, SSH CA, authorization API, and image server.
- `compute-vm-a` and `compute-vm-b`: ephemeral boot, YubiKey fixture identity, NVMe/TCP initiator, service mount dependencies.
- `desktop-vm`: iPXE/network boot path plus a dedicated persistent NVMe/TCP disk.

The first end-to-end test should prove that a PostgreSQL state volume can be attached to `compute-vm-a`, detached, authorized for `compute-vm-b`, attached there, and mounted at the same service path without changing the volume identity.
