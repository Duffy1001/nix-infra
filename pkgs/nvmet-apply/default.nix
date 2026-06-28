{ writeShellApplication }:
writeShellApplication {
  name = "nvmet-apply";
  text = builtins.readFile ./nvmet-apply.sh;
}
