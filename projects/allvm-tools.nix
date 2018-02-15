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
    tools = {
      default = {
        path = "default.nix";
        input = "allvm-tools-src";
        description = "ALLVM Tools (pinned nixpkgs)";
        shares = 100;
      };
      with-nixpkgs-master = {
        path = "default.nix";
        input = "allvm-tools-src";
        description = "ALLVM Tools (nixpkgs master)";
        inputs.nixpkgs = nixpkgs-master;
        interval = 60 * 60 * 4;
      };

      with-llvm5 = {
        path = "default.nix";
        input = "allvm-tools-src";
        inputs.allvm-tools-src = allvm-tools-llvm5;
        description = "ALLVM Tools - LLVM5 (pinned nixpkgs)";
      };
      with-llvm6 = {
        path = "default.nix";
        input = "allvm-tools-src";
        inputs.allvm-tools-src = allvm-tools-llvm6;
        description = "ALLVM Tools - LLVM6 (pinned nixpkgs)";
      };
    };
    allplay = {
      default = {
        path = "default.nix";
        input = "allvm-analysis-src";
        description = "ALLVM Analysis Tools (pinned nixpkgs)";
        shares = 100;
      };
      with-nixpkgs-master = {
        path = "default.nix";
        input = "allvm-analysis-src";
        description = "ALLVM Analysis Tools (nixpkgs master)";
        inputs.nixpkgs = nixpkgs-master;
        interval = 60 * 60 * 4;
      };
    };


    ## Build allvm-tools in various cross configurations (as well as native), using various musl branches
    cross-and-native = {
      default = {
        with-musl-pr = {
          inputs.nixpkgs = nixpkgs-musl-pr;
        };
        with-staging = {
          inputs.nixpkgs = nixpkgs-musl-staging;
        };
        with-cleanup = {
          inputs.nixpkgs = nixpkgs-musl-cleanup;
        };
      };
      llvm5 =  {
        with-musl-pr = {
          inputs.nixpkgs = nixpkgs-musl-pr;
          inputs.allvm-tools-src = allvm-tools-llvm5;
          inputs.llvmVersion = { type = "nix"; value = "5"; };
        };
        with-staging = {
          inputs.nixpkgs = nixpkgs-musl-staging;
          inputs.allvm-tools-src = allvm-tools-llvm5;
          inputs.llvmVersion = { type = "nix"; value = "5"; };
        };
        with-cleanup = {
          inputs.nixpkgs = nixpkgs-musl-cleanup;
          inputs.allvm-tools-src = allvm-tools-llvm5;
          inputs.llvmVersion = { type = "nix"; value = "5"; };
        };
      };
      llvm6 = {
        with-musl-pr = {
          inputs.nixpkgs = nixpkgs-musl-pr;
          inputs.allvm-tools-src = allvm-tools-llvm6;
          inputs.llvmVersion = { type = "nix"; value = "6"; };
        };
        with-staging = {
          inputs.nixpkgs = nixpkgs-musl-staging;
          inputs.allvm-tools-src = allvm-tools-llvm6;
          inputs.llvmVersion = { type = "nix"; value = "6"; };
        };
        with-cleanup = {
          inputs.nixpkgs = nixpkgs-musl-cleanup;
          inputs.allvm-tools-src = allvm-tools-llvm6;
          inputs.llvmVersion = { type = "nix"; value = "6"; };
        };
      };
    };
  });
in writeSpec
