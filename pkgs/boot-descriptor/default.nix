{ python3Packages }:
python3Packages.buildPythonApplication {
  pname = "boot-descriptor";
  version = "0.1.0";
  pyproject = false;
  dontUnpack = true;
  installPhase = ''
    install -Dm755 ${./boot-descriptor.py} $out/bin/boot-descriptor
  '';
}
