{ nixpkgs ? <nixpkgs>, declInput ? {} }:

let
  pkgs = import nixpkgs {};

  ## Git repo definitions, aliases
in with (import ../support/repos.nix { inherit (pkgs) lib; });
let

  defaultdefaultSettings = import ../support/default-settings.nix;
  defaultSettings = pkgs.lib.recursiveUpdate defaultdefaultSettings {
    path = "jobset/allvm-tools.nix";
    inputs = {
      allvm-tools-src = allvm-tools;
      allvm-analysis-src = allvm-analysis;
    };
  };

  writeSpec = import ./common.nix {
    inherit (pkgs) lib runCommand;
    inherit declInput jobsetsAttrs;
  };

  jobsetsAttrs = with pkgs.lib; mapAttrs (name: settings: recursiveUpdate defaultSettings settings) ({
    allvm-tools = {
      path = "default.nix";
      input = "allvm-tools-src";
      description = "ALLVM Tools";
      shares = 100;
    };
    allvm-tools-master = {
      path = "default.nix";
      input = "allvm-tools-src";
      description = "ALLVM Tools (nixpkgs master)";
      inputs.nixpkgs = nixpkgs-master;
      shares = 100;
    };
    allvm-analysis = {
      path = "default.nix";
      input = "allvm-analysis-src";
      description = "ALLVM Analysis Tools";
      shares = 100;
    };
    allvm-analysis-master = {
      path = "default.nix";
      input = "allvm-analysis-src";
      description = "ALLVM Analysis Tools (nixpkgs master)";
      inputs.nixpkgs = nixpkgs-master;
      shares = 100;
    };

    ## Build allvm-tools in various cross configurations (as well as native), using various musl branches
    allvm-tools-cross = {
      inputs.nixpkgs = nixpkgs-musl-pr;
    };
    allvm-tools-cross-staging = {
      inputs.nixpkgs = nixpkgs-musl-staging;
    };
    allvm-tools-cross-cleanup = {
      inputs.nixpkgs = nixpkgs-musl-cleanup;
    };
    allvm-tools-cross-pr-v6 = {
      inputs.nixpkgs = nixpkgs-musl-pr-v6;
    };
    allvm-tools-llvm5 = {
      inputs.nixpkgs = nixpkgs-musl-pr;
      inputs.llvmVersion = { type = "nix"; value = "5"; };
    };
    allvm-tools-llvm5-pr-v6 = {
      inputs.nixpkgs = nixpkgs-musl-pr-v6;
      inputs.llvmVersion = { type = "nix"; value = "5"; };
    };
    allvm-tools-llvm5-staging = {
      inputs.nixpkgs = nixpkgs-musl-staging;
      inputs.llvmVersion = { type = "nix"; value = "5"; };
    };
  });
in writeSpec
