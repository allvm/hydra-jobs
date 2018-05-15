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
  nixpkgs-llvm6 = nixpkgs-dtz.override { branch = "feature/llvm-6"; };
  nixpkgs-musl-native-bootstrap = nixpkgs-dtz.override { branch = "musl-native-bootstrap"; };
  nixpkgs-musl-malloc-kludge = nixpkgs-dtz.override { branch = "experimental/musl-fork-malloc-kludge"; };
  nixpkgs-musl-malloc-kludge-merged = nixpkgs-dtz.override { branch = "experimental/musl-fork-malloc-kludge-merged"; };
  nixpkgs-libgcc_s  = nixpkgs-dtz.override { branch = "fix/glibc-libgcc_s"; };
  nixpkgs-sanitizers = nixpkgs-dtz.override { branch = "experimental/musl-sanitizers"; };
  nixpkgs-dtz-staging = nixpkgs-dtz.override { branch = "staging"; };
  nixpkgs-i686-musl = nixpkgs-dtz.override { branch = "feature/i686-musl"; };
  nixpkgs-ghc-cross = nixpkgs-dtz.override { branch = "fix/ghc-cross-musl"; };
  nixpkgs-systemd = nixpkgs-dtz.override { branch = "fix/systemd-musl"; };
  nixpkgs-musl-iconv = nixpkgs-dtz.override { branch = "fix/musl-provide-iconv-tool"; };
  nixos-musl = nixpkgs-dtz.override { branch = "experimental/nixos-musl"; };
  nixos-musl-wip = nixpkgs-dtz.override { branch = "experimental/nixos-musl-wip"; };
  nixpkgs-dtz-18_03 = nixpkgs-dtz.override { branch = "dtz-18.03"; };

  nixpkgs-gcc8 = nixpkgs-master.override { branch = "gcc8"; };

  # Not the channel, but channel is tagged from this when tests pass
  nixpkgs-18_03 = nixpkgs-master.override { branch = "release-18.03"; };
  # channel:nixos-18.03
  nixos-18_03-channel = github { owner = "NixOS"; repo = "nixpkgs-channels"; branch = "nixos-18.03"; };

  allvm-tools = github { owner = "allvm"; repo = "allvm-tools"; branch = "master"; deepClone = true; };
  allvm-tools-llvm5 = allvm-tools.override { branch = "experimental/llvm-5"; };
  allvm-tools-llvm6 = allvm-tools.override { branch = "experimental/llvm-6"; };
  allvm-analysis = github { owner = "allvm"; repo = "allplay"; branch = "master"; deepClone = true; };
}
