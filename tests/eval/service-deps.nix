{ runCommand }:
runCommand "service-deps" { } ''
  touch $out
''
