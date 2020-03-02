{
  pkgs ? import <nixpkgs> {},
  nixops ? pkgs.callPackage ../../NixOS/nixops/default.nix {}
  # nixops ? pkgs.nixops
}:

let
  pythonPackages = nixops.passthru.pythonPackages;
  packet = pythonPackages.packet-python.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "packethost";
      repo = "packet-python";
      rev = "532fd866ee0cb658ec82a0d34a100cf5e8efa0fd";
      sha256 = "0g0jz4wi6njzc6iqjnkgimi5x0sp1rmbqwnd45d90c359i0ix1bm";
    };
    patches = [];
    buildInputs = old.buildInputs ++ [
      pythonPackages.pytestrunner
    ];
  });
in
nixops.passthru.buildPluginPackage rec {
  pname = "nixops-packet";
  version = "0.1";

  src = ./.;

  prePatch = ''
    for i in setup.py; do
      substituteInPlace $i --subst-var-by version ${version}
    done
  '';

  nativeBuildInputs = [
    pythonPackages.mypy
    pythonPackages.nose
    pythonPackages.coverage
  ];

  propagatedBuildInputs = [
    packet
  ];

  postInstall = ''
    mkdir -p $out/share/nix/nixops-packet
    cp -av nix/* $out/share/nix/nixops-packet
  '';

  doCheck = true;
}
