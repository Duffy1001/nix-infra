{ runCommand }:
runCommand "volume-select" { } ''
  touch $out
''
