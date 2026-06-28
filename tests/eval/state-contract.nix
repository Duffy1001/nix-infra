{ runCommand }:
runCommand "state-contract" { } ''
  touch $out
''
