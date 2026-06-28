{ runCommand }:
runCommand "names" { } ''
  touch $out
''
