{ nixpkgs ? <nixpkgs>, declInput ? {} }:

let
  pkgs = import nixpkgs {};

  defaultSettings = import ../support/default-settings.nix { inherit (pkgs) lib; };

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
    };
    "native-misc-musl64-${name}" = {
      path = "jobset/musl-misc.nix";
      inputs.nixpkgs = repo;
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
    // (jobsFor "old" nixpkgs-musl)
    // (jobsFor "cleanup" nixpkgs-musl-cleanup)
    // (jobsFor "PR" nixpkgs-musl-pr)
    // (jobsFor "next" nixpkgs-musl-next)
    // rec {
    #bootstrap-tools = {
    #  keep = 2;
    #  input = "nixpkgs";
    #  path = "pkgs/stdenv/linux/make-bootstrap-tools.nix";
    #};


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
