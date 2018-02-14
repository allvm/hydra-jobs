{ lib }:

let
  gitlab = import ./gitlab.nix { inherit lib; };
in rec {
  ## Git repo definitions, aliases
  allvm = gitlab { repo = "allvm-nixpkgs"; };
  nixpkgs-master = {
    type = "git";
    value = "https://github.com/NixOS/nixpkgs";
  };
  nixpkgs-musl = allvm.override { branch = "feature/musl"; };
  nixpkgs-musl-cleanup = allvm.override { branch = "feature/musl-cleanup"; };
  nixpkgs-musl-pr = {
    type = "git";
    value = "https://github.com/dtzWill/nixpkgs feature/musl";
  };
  nixpkgs-musl-next = {
    type = "git";
    value = "https://github.com/dtzWill/nixpkgs feature/musl-next";
  };
  nixpkgs-musl-pr-v6 = {
    type = "git";
    value = "https://github.com/dtzWill/nixpkgs musl-pr-6";
  };
  nixpkgs-musl-lib-no-llvm = {
    type = "git";
    value = "https://github.com/dtzWill/nixpkgs feature/musl-lib-no-llvm";
  };
  nixpkgs-musl-staging = {
    type = "git";
    value = "https://github.com/dtzWill/nixpkgs staging-musl-merged";
  };

  allvm-tools = { type = "git"; value = "https://github.com/allvm/allvm-tools master 1"; };
  allvm-tools-llvm5 = { type = "git"; value = "https://github.com/allvm/allvm-tools experimental/llvm-5 1"; };
  allvm-tools-llvm6 = { type = "git"; value = "https://github.com/allvm/allvm-tools experimental/llvm-6 1"; };
  allvm-analysis = { type = "git"; value = "https://github.com/allvm/allplay master 1"; };
}
