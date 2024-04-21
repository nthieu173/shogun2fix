{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  packages = [
    pkgs.gcc_multi
    pkgs.gccMultiStdenv
    pkgs.gitFull
    pkgs.glibc_multi
  ];
}