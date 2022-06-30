{ pkgs ? import <nixpkgs> {}}:

with pkgs;
pkgs.mkShell {
  nativeBuildInputs = [
    pre-commit
  ];
}
