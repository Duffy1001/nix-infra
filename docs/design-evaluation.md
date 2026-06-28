# Design Evaluation

## Verdict

The best version of this idea is a **single persistent root storage/control node** plus **stateless compute hosts** that attach all durable service data over **NVMe/TCP only**. Compute machines should be replaceable, and stateful services should move by changing service placement and volume ACLs rather than by copying disks.

## Non-negotiable constraints

- Use NVMe/TCP as the only data-plane transport for persistent service and host disks.
- Keep one root node as the persistent authority for storage, boot artifacts, authorization, and SSH trust.
- Make every stateful service volume independently movable between eligible compute hosts.
- Test root and compute behavior with QEMU VMs until real NVMe drive properties are known.

## Naming decision

Use **compute** for machines that run services and consume remote state. Use **desktop** for an interactive compute host with optional iPXE boot and a dedicated persistent NVMe/TCP disk. Avoid designing around the desktop; it is an additional host profile, not a special case in the storage model.

## Root responsibilities

- Own ZFS pools and zvol-backed state volumes.
- Export volumes over NVMe/TCP.
- Authorize hosts and YubiKey-backed identities to attach volumes.
- Serve iPXE, ISO, and netboot artifacts.
- Act as the SSH certificate authority trust anchor so all booted machines trust keys signed by root.

## Service mobility model

A service volume should not be named after the current compute host unless it is truly host-local. For movable services, use stable service names such as `postgres/main` and express eligible placements separately with `movableBetween = [ "app01" "app02" ]`.

## QEMU-first testing model

Before hardware details are available, VM tests should model:

1. A root VM with a file-backed ZFS pool.
2. One or more compute VMs booting an ephemeral profile.
3. NVMe/TCP export and attach across the QEMU network.
4. Service startup ordering after state mounts.
5. Moving a service from one compute VM to another by changing placement and ACLs.
6. A desktop VM booting via the same network-boot path and attaching a dedicated persistent NVMe/TCP disk.
