Here’s a clean project layout for the **ephemeral machines + remote per-service state** design.

```text id="t30ei7"
nix-home-infra/
├── flake.nix
├── flake.lock
├── README.md
│
├── lib/
│   ├── default.nix
│   ├── names.nix
│   ├── systemd.nix
│   ├── zfs.nix
│   └── nvme.nix
│
├── site/
│   ├── default.nix
│   ├── hosts.nix
│   ├── identity.nix
│   ├── networks.nix
│   ├── storage.nix
│   └── services.nix
│
├── hosts/
│   ├── root/
│   │   ├── default.nix
│   │   ├── hardware.nix
│   │   ├── disko.nix
│   │   └── storage-node.nix
│   │
│   ├── app01/
│   │   ├── default.nix
│   │   └── services.nix
│   │
│   ├── app02/
│   │   ├── default.nix
│   │   └── services.nix
│   │
│   └── laptop01/
│       ├── default.nix
│       └── services.nix
│
├── modules/
│   ├── state/
│   │   ├── contract.nix
│   │   ├── service-bindings.nix
│   │   ├── volume-select.nix
│   │   └── assertions.nix
│   │
│   ├── identity/
│   │   ├── contract.nix
│   │   ├── yubikey.nix
│   │   ├── host-identity.nix
│   │   └── volume-acl.nix
│   │
│   ├── boot/
│   │   ├── ephemeral-root.nix
│   │   ├── shared-iso.nix
│   │   ├── netboot.nix
│   │   └── host-profile-fetch.nix
│   │
│   ├── root/
│   │   ├── disko-zpool.nix
│   │   ├── zvol-plan.nix
│   │   ├── zvol-create.nix
│   │   ├── nvmet-plan.nix
│   │   ├── nvmet-export.nix
│   │   ├── authorization-api.nix
│   │   └── image-server.nix
│   │
│   ├── client/
│   │   ├── auth.nix
│   │   ├── nvme-connect.nix
│   │   ├── fs-init.nix
│   │   ├── mounts.nix
│   │   ├── service-deps.nix
│   │   └── cleanup.nix
│   │
│   └── services/
│       ├── postgresql-state.nix
│       ├── forgejo-state.nix
│       ├── prometheus-state.nix
│       ├── grafana-state.nix
│       └── generic-stateful-service.nix
│
├── profiles/
│   ├── base.nix
│   ├── ephemeral-leaf.nix
│   ├── storage-root.nix
│   ├── app-server.nix
│   ├── monitoring.nix
│   └── laptop.nix
│
├── images/
│   ├── shared-iso.nix
│   ├── netboot.nix
│   └── installer.nix
│
├── keys/
│   ├── yubikeys/
│   │   ├── app01.pub
│   │   ├── app02.pub
│   │   └── laptop01.pub
│   │
│   ├── hostnqn/
│   │   ├── app01
│   │   ├── app02
│   │   └── laptop01
│   │
│   └── ssh/
│       ├── root-storage.pub
│       └── admin.pub
│
├── pkgs/
│   ├── default.nix
│   ├── state-auth/
│   │   ├── default.nix
│   │   └── state-auth.sh
│   │
│   ├── state-connect/
│   │   ├── default.nix
│   │   └── state-connect.sh
│   │
│   ├── nvmet-apply/
│   │   ├── default.nix
│   │   └── nvmet-apply.sh
│   │
│   └── boot-descriptor/
│       ├── default.nix
│       └── boot-descriptor.py
│
├── tests/
│   ├── eval/
│   │   ├── state-contract.nix
│   │   ├── names.nix
│   │   ├── volume-select.nix
│   │   ├── zvol-plan.nix
│   │   ├── nvmet-plan.nix
│   │   └── service-deps.nix
│   │
│   ├── vm/
│   │   ├── root-zvol-create.nix
│   │   ├── nvmet-export.nix
│   │   ├── client-nvme-connect.nix
│   │   ├── service-state-mount.nix
│   │   └── full-root-app01.nix
│   │
│   └── fixtures/
│       ├── site-small.nix
│       ├── site-two-hosts.nix
│       └── fake-yubikey.nix
│
└── docs/
    ├── architecture.md
    ├── state-volumes.md
    ├── yubikey-identity.md
    ├── root-storage-node.md
    └── recovery.md
```

## Core intent

The layout separates four concerns:

```text id="vgul1l"
site/       declares what should exist
modules/    implement reusable behavior
hosts/      assemble actual machines
tests/      prove each layer independently
```

The most important rule:

```text id="av9pkc"
site declares state.
root realizes state.
leaf machines consume state.
services depend on mounted state.
```

## `site/`

This is the source of truth.

```text id="4vc7tz"
site/
├── hosts.nix      # app01, app02, root, laptop01
├── identity.nix   # YubiKey → host identity mapping
├── networks.nix   # storage network, mgmt network, addresses
├── storage.nix    # pools, backends, volume defaults
└── services.nix   # which services run where
```

Example shape:

```nix id="b2ayj0"
{
  hosts.app01 = {
    role = "app-server";
    identity.yubikey = "yk-app01";
    address.storage = "10.10.0.11";
  };

  state.volumes."postgres/app01/main" = {
    ownerHost = "app01";
    service = "postgresql";
    size = "100G";
    mountpoint = "/var/lib/postgresql";
    fsType = "xfs";
    pool = "tank";
  };
}
```

## `modules/state/`

These modules define the storage contract.

```text id="hka5wl"
modules/state/
├── contract.nix          # site.state.volumes option schema
├── service-bindings.nix  # services can request volumes
├── volume-select.nix     # each leaf selects its own volumes
└── assertions.nix        # validate ownership, sizes, paths, conflicts
```

This layer should be mostly pure Nix.

It should not create zvols.
It should not connect NVMe.
It should not mount filesystems.

## `modules/root/`

These only run on the storage node called `root`.

```text id="5m9wlk"
modules/root/
├── disko-zpool.nix        # base disk layout and ZFS pool
├── zvol-plan.nix          # pure plan: state volumes → zvols
├── zvol-create.nix        # systemd services that create/grow zvols
├── nvmet-plan.nix         # pure plan: zvols → NVMe exports
├── nvmet-export.nix       # systemd/configfs NVMe target setup
├── authorization-api.nix  # YubiKey proof → allowed volumes
└── image-server.nix       # serves shared ISO/netboot artifacts
```

The root flow is:

```text id="xkte5u"
site.state.volumes
  → zvol-plan
  → zvol-create
  → nvmet-plan
  → nvmet-export
```

## `modules/client/`

These run on ephemeral leaf machines.

```text id="fgw7d7"
modules/client/
├── auth.nix          # YubiKey authentication
├── nvme-connect.nix  # connect allowed NVMe/TCP volumes
├── fs-init.nix       # mkfs only if blank
├── mounts.nix        # fileSystems entries
├── service-deps.nix  # services start after mounts
└── cleanup.nix       # disconnect on shutdown if desired
```

The client flow is:

```text id="ha7wzj"
boot ephemeral system
  → authenticate with YubiKey
  → receive allowed volumes
  → nvme connect
  → format if empty
  → mount
  → start services
```

## `modules/identity/`

Identity is separate from storage.

```text id="fbci1i"
modules/identity/
├── contract.nix       # identity schema
├── yubikey.nix        # YubiKey tooling/options
├── host-identity.nix  # hostnqn, host identity, auth name
└── volume-acl.nix     # host identity → allowed volumes
```

This lets you change authentication without rewriting storage modules.

## `modules/boot/`

Boot remains ephemeral.

```text id="6cixlx"
modules/boot/
├── ephemeral-root.nix       # tmpfs root, volatile /etc, volatile /var
├── shared-iso.nix           # generic ISO
├── netboot.nix              # optional PXE/netboot image
└── host-profile-fetch.nix   # optional: fetch host profile after auth
```

The system image should be disposable. The service data should not be.

## `modules/services/`

Each stateful service gets a tiny adapter.

```text id="w8ef83"
modules/services/
├── postgresql-state.nix
├── forgejo-state.nix
├── prometheus-state.nix
├── grafana-state.nix
└── generic-stateful-service.nix
```

Example intent:

```nix id="0e3i3i"
services.postgresql = {
  enable = true;

  state = {
    enable = true;
    size = "100G";
    mountpoint = "/var/lib/postgresql";
  };
};
```

The adapter translates that into a `site.state.volumes` entry.

## `profiles/`

Profiles compose modules for common machine types.

```text id="wxopbo"
profiles/
├── base.nix
├── ephemeral-leaf.nix
├── storage-root.nix
├── app-server.nix
├── monitoring.nix
└── laptop.nix
```

Example:

```nix id="jckjan"
# profiles/ephemeral-leaf.nix
{
  imports = [
    ../modules/boot/ephemeral-root.nix
    ../modules/identity/yubikey.nix
    ../modules/client/auth.nix
    ../modules/client/nvme-connect.nix
    ../modules/client/fs-init.nix
    ../modules/client/mounts.nix
    ../modules/client/service-deps.nix
  ];
}
```

## `hosts/`

Actual host configs stay small.

```nix id="32bpwt"
# hosts/app01/default.nix
{
  imports = [
    ../../profiles/base.nix
    ../../profiles/ephemeral-leaf.nix
    ../../profiles/app-server.nix
    ./services.nix
  ];

  networking.hostName = "app01";
}
```

```nix id="6xj33x"
# hosts/root/default.nix
{
  imports = [
    ../../profiles/base.nix
    ../../profiles/storage-root.nix
    ./hardware.nix
    ./disko.nix
  ];

  networking.hostName = "root";
}
```

## `pkgs/`

Small scripts become packages, not inline shell blobs.

```text id="ej1ryq"
pkgs/
├── state-auth/       # talks to YubiKey and root auth API
├── state-connect/    # connects NVMe volumes from descriptor
├── nvmet-apply/      # applies NVMe target configfs plan
└── boot-descriptor/  # root-side descriptor generator/API
```

This keeps modules readable and makes the scripts testable.

## `tests/`

Use three levels of testing.

```text id="i8mgmb"
tests/eval/   # pure Nix module tests
tests/vm/     # NixOS VM tests
tests/fixtures/
```

Start with eval tests for:

```text id="6brexv"
state contract
name generation
volume selection
zvol planning
NVMe export planning
service mount dependencies
```

Then VM tests for:

```text id="bj5a3v"
zvol creation
NVMe export
client connect
filesystem init
mount before service start
```

## Suggested build targets

Your `flake.nix` should expose:

```text id="8sd7gz"
nixosConfigurations.root
nixosConfigurations.app01
nixosConfigurations.app02

packages.x86_64-linux.sharedIso
packages.x86_64-linux.netbootImage

checks.x86_64-linux.state-contract
checks.x86_64-linux.volume-select
checks.x86_64-linux.zvol-plan
checks.x86_64-linux.full-root-app01
```

Final shape:

```text id="fe0lc5"
root is persistent.
leaves are ephemeral.
services declare state.
state becomes zvols.
zvols become NVMe/TCP exports.
authorized leaves mount only what they need.
```
