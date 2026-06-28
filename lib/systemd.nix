{ lib }:
{
  mountUnitFor = path: "${lib.removePrefix "/" (lib.replaceStrings [ "/" ] [ "-" ] path)}.mount";
}
