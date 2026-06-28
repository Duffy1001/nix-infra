{ runCommand }:
runCommand "zvol-plan" { } ''
  touch $out
''
