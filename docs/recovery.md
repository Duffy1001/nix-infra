# Recovery

## Root pool import

1. Boot a rescue image with ZFS support.
2. Import the state pool without mounting service data: `zpool import -N tank`.
3. Inspect declared zvols with `zfs list -t volume tank` and compare them with the generated root plan at `/etc/nix-infra/nvmet-plan.json`.
4. Roll back only after snapshot verification; service volume names are stable and should not be renamed during recovery.

## Zvol recovery

- Each state volume is declared in `site/storage.nix` and realized as a deterministic zvol path by the root zvol plan.
- Recreate a missing empty zvol by rebuilding the root host; `zvol-*.service` creates absent volumes and grows existing volumes.
- For data recovery, restore into the same zvol path so compute hosts keep the same NVMe NQN and mountpoint.

## Host identity replacement

1. Replace the affected `keys/hostnqn/<host>` fixture and, if needed, the YubiKey public-key fixture.
2. Update `site/identity.nix` only if the inventory identity name changes.
3. Rebuild the root host first so the NVMe ACL plan includes the replacement identity.
4. Rebuild or reboot the compute host so it reconnects with the new host NQN.

## SSH CA rotation

1. Add the new CA public key under `keys/ssh/` and update `modules/identity/ssh-trust-anchor.nix` if the path changes.
2. Deploy the trust anchor to compute hosts before retiring certificates signed by the old CA.
3. Re-issue host/user certificates from the root CA workflow.

## Service re-placement

Service data moves by changing `movableBetween` and host/service placement in `site/storage.nix` and `site/services.nix`. Do not rename the volume. Rebuild root to update ACLs, stop the service on the old host, disconnect the NVMe session, then start it on the new authorized host.
