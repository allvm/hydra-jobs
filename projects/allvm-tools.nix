{ nixpkgs ? <nixpkgs>, declInput ? {} }:

let
  pkgs = import nixpkgs {};
  inherit (pkgs) lib;

  ## Git repo definitions, aliases
in with (import ../support/repos.nix { inherit lib; });
let

  defaultdefaultSettings = import ../support/default-settings.nix;
  defaultSettings = lib.recursiveUpdate defaultdefaultSettings {
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

  inherit (lib) recursiveUpdate;
  mkJob = x: recursiveUpdate defaultSettings x // { isJob = true; };
  flattenJobAttrs = x:
    let
      # Convert attr paths of jobs to name/settings pairs
      isJob = as: as.isJob or false;
      mappedToNamedJobs = lib.mapAttrsRecursiveCond
        (as : !isJob as)
        (path: value: { name = lib.concatStringsSep "." path; inherit value; isNamedJob = true; })
        x;
      isNamedJob = as: as.isNamedJob or false;
    in lib.listToAttrs (lib.collect isNamedJob mappedToNamedJobs);

  jobsetsAttrs = flattenJobAttrs {
    tools = rec {
      default = mkJob {
        path = "default.nix";
        input = "allvm-tools-src";
        description = "ALLVM Tools (pinned nixpkgs)";
        shares = 100;
      };
      with-nixpkgs-master = recursiveUpdate default {
        description = "ALLVM Tools (nixpkgs master)";
        inputs.nixpkgs = nixpkgs-master;
        interval = 60 * 60 * 4;
      };

      with-llvm5 = recursiveUpdate default {
        inputs.allvm-tools-src = allvm-tools-llvm5;
        description = "ALLVM Tools - LLVM5 (pinned nixpkgs)";
      };
      with-llvm6 = recursiveUpdate default {
        inputs.allvm-tools-src = allvm-tools-llvm6;
        description = "ALLVM Tools - LLVM6 (pinned nixpkgs)";
      };
    };
    allplay = rec {
      default = mkJob {
        path = "default.nix";
        input = "allvm-analysis-src";
        description = "ALLVM Analysis Tools (pinned nixpkgs)";
        shares = 100;
      };
      with-nixpkgs-master = recursiveUpdate default {
        description = "ALLVM Analysis Tools (nixpkgs master)";
        inputs.nixpkgs = nixpkgs-master;
        interval = 60 * 60 * 4;
      };
    };


    ## Build allvm-tools in various cross configurations (as well as native), using various musl branches
    cross-and-native =
      let
        genJobs = base: {
          with-musl-pr = recursiveUpdate base {
            inputs.nixpkgs = nixpkgs-musl-pr;
          };
          with-staging = recursiveUpdate base {
            inputs.nixpkgs = nixpkgs-musl-staging;
          };
          with-cleanup = recursiveUpdate base {
            inputs.nixpkgs = nixpkgs-musl-cleanup;
          };
          with-llvm-musl = recursiveUpdate base {
            inputs.nixpkgs = nixpkgs-llvm-musl;
          };
          with-llvm6 = recursiveUpdate base {
            inputs.nixpkgs = nixpkgs-llvm6;
          };
        };
      in pkgs.lib.mapAttrs (_: x: genJobs x) {
        default = mkJob {};
        llvm5 = mkJob {
          inputs.allvm-tools-src = allvm-tools-llvm5;
          inputs.llvmVersion = { type = "nix"; value = "5"; };
        };
        llvm6 = mkJob {
          inputs.allvm-tools-src = allvm-tools-llvm6;
          inputs.llvmVersion = { type = "nix"; value = "6"; };
        };
      };

  };
in writeSpec
