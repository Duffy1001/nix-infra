{ pkgs }:
{
  state-auth = pkgs.callPackage ./state-auth { };
  state-connect = pkgs.callPackage ./state-connect { };
  nvmet-apply = pkgs.callPackage ./nvmet-apply { };
  boot-descriptor = pkgs.callPackage ./boot-descriptor { };
}
