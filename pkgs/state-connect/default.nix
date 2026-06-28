{ writeShellApplication }:
writeShellApplication {
  name = "state-connect";
  text = builtins.readFile ./state-connect.sh;
}
