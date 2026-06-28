{ lib, config, ... }:
let
  site = import ../../site;
  infraLib = import ../../lib { inherit lib; };
  rootAddress = site.networks.storage.rootAddress;
  defaultPort = infraLib.nvme.defaultPort;
  hosts = site.hosts;
  allowedHosts = volume:
    lib.unique ((volume.movableBetween or [ ]) ++ lib.optional (volume ? ownerHost) volume.ownerHost);
  mkPlan = name: volume:
    let
      zvol = config.infra.root.zvolPlan.${name};
      safe = infraLib.names.volumeName name;
    in {
      inherit name;
      nqn = infraLib.nvme.nqnFor "root" safe;
      listen = { trtype = "tcp"; adrfam = "ipv4"; traddr = rootAddress; trsvcid = toString defaultPort; };
      namespace = { path = zvol.device; uuidSeed = safe; };
      allowedHosts = map (host: {
        name = host;
        hostnqnFile = "${toString ../../keys/hostnqn}/${host}";
        storageAddress = hosts.${host}.address.storage or null;
      }) (allowedHosts volume);
    };
in
{
  options.infra.root.nvmetPlan = lib.mkOption {
    type = lib.types.attrs;
    default = lib.mapAttrs mkPlan (site.storage.state.volumes or { });
    readOnly = true;
    description = "Pure plan mapping zvols to NVMe/TCP exports.";
  };
}
