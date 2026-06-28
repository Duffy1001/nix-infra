{
  hosts = import ./hosts.nix;
  identity = import ./identity.nix;
  networks = import ./networks.nix;
  storage = import ./storage.nix;
  services = import ./services.nix;
}
