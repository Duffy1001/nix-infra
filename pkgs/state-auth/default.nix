{ writeShellApplication }:
writeShellApplication {
  name = "state-auth";
  text = builtins.readFile ./state-auth.sh;
}
