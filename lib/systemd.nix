{ lib }:
{
  mountUnitFor = path: "${lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" path)}.mount";
}
