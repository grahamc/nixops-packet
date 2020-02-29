{ nixopsSrc ? { outPath = ./.; revCount = 0; shortRev = "abcdef"; rev = "HEAD"; }
, nixops
, officialRelease ? false
, nixpkgs ? <nixpkgs>
}:

let
  pkgs = import nixpkgs { };
  version = "1.6.1" + (if officialRelease then "" else "pre${toString nixopsSrc.revCount}_${nixopsSrc.shortRev}");
  packet = pkgs.python3Packages.packet-python.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "packethost";
      repo = "packet-python";
      rev = "532fd866ee0cb658ec82a0d34a100cf5e8efa0fd";
      sha256 = "0g0jz4wi6njzc6iqjnkgimi5x0sp1rmbqwnd45d90c359i0ix1bm";
    };
    patches = [];
    buildInputs = old.buildInputs ++ [ pkgs.python3Packages.pytestrunner ];
  });

in

rec {
  build = pkgs.lib.genAttrs [ "x86_64-linux" "i686-linux" "x86_64-darwin" ] (system:
    with import nixpkgs { inherit system; };

    python3Packages.buildPythonPackage rec {
      name = "nixops-packet-${version}";
      namePrefix = "";

      src = ./.;

      prePatch = ''
        for i in setup.py; do
          substituteInPlace $i --subst-var-by version ${version}
        done
      '';


      nativeBuildInputs = [ python37Packages.mypy python3Packages.nose python3Packages.coverage (builtins.trace "${nixops."${system}"}" nixops."${system}") ];

      propagatedBuildInputs = [
        packet
      ];

      postInstall =
        ''
          mkdir -p $out/share/nix/nixops-packet
          cp -av nix/* $out/share/nix/nixops-packet
        '';


      # For "nix-build --run-env".
      shellHook = ''
        export PYTHONPATH=$(pwd):$PYTHONPATH
        export PATH=$(pwd)/scripts:${openssh}/bin:$PATH
      '';

      doCheck = true;

    });

  }
