# SSH Trust Anchor

The root node is the SSH trust anchor. Booted machines should trust host and user keys signed by the root SSH CA, which allows key rotation and YubiKey-backed user keys without distributing every individual public key to every host.

Initial implementation notes:

- Root owns the CA public key published in `keys/ssh/root-ca.pub`.
- Compute, laptop, and desktop profiles import the SSH trust-anchor module.
- User authentication should prefer SSH certificates backed by YubiKey-held private keys.
- CA rotation must be documented before deployment.
