{ nixpkgs ? <nixpkgs>, declInput ? {} }:

let
  pkgs = import nixpkgs {};

  defaultSettings = import ../support/default-settings.nix;

  ## Git repo definitions, aliases
in with (import ../support/repos.nix { inherit (pkgs) lib; });
let

  ## Jobset generation
  crossJobset = crossSystemExampleName: nixpkgs_repo: {
    path = "jobset/cross.nix";
    inputs.crossSystemExampleName = { type = "string"; value = crossSystemExampleName; };
    inputs.nixpkgs = nixpkgs_repo;
  };
  crossMuslJobs = name: repo: {
    "cross-musl64-${name}" = crossJobset "musl64" repo;
    "cross-musl32-${name}" = crossJobset "musl32" repo;
    "cross-muslpi-${name}" = crossJobset "muslpi" repo;
    "cross-aarch64-${name}" = crossJobset "aarch64-multiplatform-musl" repo;
  };
  nativeJobs = name: repo: {
    "native-small-musl64-${name}" = {
      path = "jobset/musl-small.nix";
      inputs.nixpkgs = repo;
      shares = 200;
    };
    "native-misc-musl64-${name}" = {
      path = "jobset/musl-misc.nix";
      inputs.nixpkgs = repo;
      shares = 200;
    };
  };
  jobsFor = name: repo:
    (crossMuslJobs name repo) // (nativeJobs name repo);

  writeSpec = import ./common.nix {
    inherit (pkgs) lib runCommand;
    inherit declInput jobsetsAttrs;
  };

  jobsetsAttrs = with pkgs.lib; mapAttrs (name: settings: recursiveUpdate defaultSettings settings) (
    {}
    #// (jobsFor "old" nixpkgs-musl)
    // (jobsFor "cleanup" nixpkgs-musl-cleanup)
    // (jobsFor "dtz-staging" nixpkgs-dtz-staging)
    // (jobsFor "dtz" nixpkgs-dtz)
    // (jobsFor "musl-bootstrap" nixpkgs-musl-native-bootstrap)
    // (jobsFor "musl-malloc-kludge" nixpkgs-musl-malloc-kludge)
    // (jobsFor "musl-malloc-kludge-merged" nixpkgs-musl-malloc-kludge-merged)
    // (jobsFor "libgcc_s" nixpkgs-libgcc_s)
    // (jobsFor "sanitizers" nixpkgs-sanitizers)
    // (jobsFor "i686-musl" nixpkgs-i686-musl)
    // (jobsFor "ghc-cross" nixpkgs-ghc-cross)
    // (jobsFor "systemd" nixpkgs-systemd)
    // (jobsFor "18.03" nixpkgs-18_03)
    // (jobsFor "nixos-18.03" nixos-18_03-channel)
    #// (jobsFor "nix-2" nixpkgs-nix-2)
    // rec {
    #bootstrap-tools = {
    #  keep = 2;
    #  input = "nixpkgs";
    #  path = "pkgs/stdenv/linux/make-bootstrap-tools.nix";
    #};

    bootstrap-tools = {
      input = "nixpkgs";
      inputs.nixpkgs = nixpkgs-musl-native-bootstrap;
      path = "pkgs/stdenv/linux/make-bootstrap-tools.nix";
      inputs.localSystem = {
        type = "nix";
        value = ''{config=\"x86_64-unknown-linux-musl\";}'';
      };
    };

    cross-mingwW64 = {
      path = "jobset/cross.nix";
      enabled = "0";
      inputs.crossSystemExampleName = { type = "string"; value = "mingwW64"; };
      inputs.nixpkgs = nixpkgs-musl;
    };

    nixpkgs-manual = {
      path = "jobset/manual.nix";
      enabled = "0";
    };

    nixpkgs-manual-musl = {
      path = "jobset/manual.nix";
      enabled = "0";
      inputs.nixpkgs = nixpkgs-musl;
    };
  });
in writeSpec
