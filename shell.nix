
{ pkgs ? import <nixpkgs> {} }:

let

  overrides = import ./overrides.nix { inherit pkgs; };

in pkgs.mkShell {

  buildInputs = [
    pkgs.poetry
  ];

}
