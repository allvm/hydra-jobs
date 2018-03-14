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
  nixpkgs-musl-staging = nixpkgs-dtz.override { branch = "staging-musl-merged"; };
  nixpkgs-llvm6 = nixpkgs-dtz.override { branch = "feature/llvm-6"; };
  nixpkgs-musl-native-bootstrap = nixpkgs-dtz.override { branch = "musl-native-bootstrap"; };
  nixpkgs-musl-malloc-kludge = nixpkgs-dtz.override { branch = "experimental/musl-fork-malloc-kludge"; };
  nixpkgs-libgcc_s  = nixpkgs-dtz.override { branch = "fix/glibc-libgcc_s"; };
  nixpkgs-sanitizers = nixpkgs-dtz.override { branch = "experimental/musl-sanitizers"; };

  nixpkgs-nix-2  = nixpkgs-master.override { branch = "nix-2.0"; };

  allvm-tools = github { owner = "allvm"; repo = "allvm-tools"; branch = "master"; deepClone = true; };
  allvm-tools-llvm5 = allvm-tools.override { branch = "experimental/llvm-5"; };
  allvm-tools-llvm6 = allvm-tools.override { branch = "experimental/llvm-6"; };
  allvm-analysis = github { owner = "allvm"; repo = "allplay"; branch = "master"; deepClone = true; };
}
