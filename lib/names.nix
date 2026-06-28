{ lib }:
{
  volumeName = name: lib.replaceStrings [ "/" " " ] [ "-" "-" ] name;
  zvolPath = pool: name: "${pool}/${lib.replaceStrings [ "/" " " ] [ "/" "-" ] name}";
  systemdEscape = name: lib.replaceStrings [ "/" ":" " " ] [ "-" "-" "-" ] name;
}
