{ lib, config, ... }:
let
  site = import ../../site;
  volumes = site.storage.state.volumes or { };
  hosts = site.hosts or { };
  pools = site.storage.pools or { };
  names = lib.attrNames volumes;
  mountpoints = map (n: volumes.${n}.mountpoint) names;
  duplicates = xs: lib.unique (lib.filter (x: (lib.count (y: y == x) xs) > 1) xs);
  hostKnown = h: lib.hasAttr h hosts;
  volumeAssertions = lib.concatMap (name:
    let v = volumes.${name}; candidates = (v.movableBetween or [ ]) ++ lib.optional (v ? ownerHost) v.ownerHost;
    in [
      { assertion = (v.transport or "nvme-tcp") == "nvme-tcp"; message = "${name}: persistent volumes must use nvme-tcp transport"; }
      { assertion = v ? size; message = "${name}: missing size"; }
      { assertion = v ? mountpoint; message = "${name}: missing mountpoint"; }
      { assertion = lib.hasAttr (v.pool or site.storage.volumeDefaults.pool) pools; message = "${name}: references unknown pool"; }
      { assertion = lib.all hostKnown candidates; message = "${name}: references unknown host in ownerHost/movableBetween"; }
      { assertion = candidates != [ ]; message = "${name}: must declare ownerHost or movableBetween"; }
    ]) names;
in {
  assertions = volumeAssertions ++ [
    { assertion = duplicates mountpoints == [ ]; message = "state volume mountpoints must be unique"; }
    { assertion = lib.all (n: builtins.match "[A-Za-z0-9._/-]+" n != null) names; message = "state volume names contain unsupported characters"; }
  ];
}
