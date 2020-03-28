  { nixpkgs ? <nixpkgs>
  , pkgs ? import nixpkgs {}
  }:
  let
    overrides = import ./overrides.nix { inherit pkgs; };
  in pkgs.poetry2nix.mkPoetryApplication {
    src = pkgs.lib.cleanSource ./.;
    pyproject = ./pyproject.toml;
    poetrylock = ./poetry.lock;

    overrides = [
      pkgs.poetry2nix.defaultPoetryOverrides
      overrides
    ];
  }
