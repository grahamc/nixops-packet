  { pkgs ? import <nixpkgs> {} }:
  let
    overrides = import ./overrides.nix { inherit pkgs; };
  in pkgs.mkShell {
    buildInputs = [
      (pkgs.poetry2nix.mkPoetryEnv {
        poetrylock = ./poetry.lock;
        overrides = [
          pkgs.poetry2nix.defaultPoetryOverrides
          overrides
        ];
      })
      pkgs.poetry
    ];
  }
