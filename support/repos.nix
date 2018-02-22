{ lib }:

let
  gitlab = import ./gitlab.nix { inherit lib; };
  github = import ./github.nix { inherit lib; };
in rec {
  ## Git repo definitions, aliases
  nixpkgs-master = github { owner = "NixOS"; repo = "nixpkgs"; };

  allvm = gitlab { repo = "allvm-nixpkgs"; };
  nixpkgs-musl = allvm.override { branch = "feature/musl"; };
  nixpkgs-musl-cleanup = allvm.override { branch = "feature/musl-cleanup"; };

  nixpkgs-dtz = github { owner = "dtzWill"; repo = "nixpkgs"; };
  nixpkgs-musl-pr = nixpkgs-dtz.override { branch = "feature/musl"; };
  nixpkgs-musl-next = nixpkgs-dtz.override { branch = "feature/musl-next"; };
  nixpkgs-musl-pr-v6 = nixpkgs-dtz.override { branch = "musl-pr-6"; };
  nixpkgs-musl-lib-no-llvm = nixpkgs-dtz.override { branch = "feature/musl-lib-no-llvm"; };
  nixpkgs-musl-staging = nixpkgs-dtz.override { branch = "staging-musl-merged"; };
  nixpkgs-llvm6 = nixpkgs-dtz.override { branch = "feature/llvm-6"; };
  nixpkgs-gcc7 = nixpkgs-dtz.override { branch = "fix/gcc7"; };
  nixpkgs-gcc7-musl = nixpkgs-dtz.override { branch = "fix/gcc7-musl"; };

  nixpkgs-musl-git = nixpkgs-dtz.override { branch = "experimental/musl-git"; };

  allvm-tools = github { owner = "allvm"; repo = "allvm-tools"; branch = "master"; deepClone = true; };
  allvm-tools-llvm5 = allvm-tools.override { branch = "experimental/llvm-5"; };
  allvm-tools-llvm6 = allvm-tools.override { branch = "experimental/llvm-6"; };
  allvm-analysis = github { owner = "allvm"; repo = "allplay"; branch = "master"; deepClone = true; };
}
