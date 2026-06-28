{ runCommand }:
runCommand "nvmet-plan" { } ''
  touch $out
''
