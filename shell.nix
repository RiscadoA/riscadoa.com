{ pkgs ? import <nixpkgs> {} }:
with pkgs; mkShell {
  nativeBuildInputs = [
    ruby.devEnv
    bundix
  ];
}