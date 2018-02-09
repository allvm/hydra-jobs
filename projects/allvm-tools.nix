{ nixpkgs ? <nixpkgs>, declInput ? {} }:

let
  pkgs = import nixpkgs {};
  gitlab = import ../support/gitlab.nix { inherit (pkgs) lib; };

  defaultSettings = import ../support/default-settings.nix { inherit (pkgs) lib; };

  ## Git repo definitions, aliases
in with (import ../support/repos.nix { inherit (pkgs) lib; });
let

  writeSpec = import ./common.nix {
    inherit (pkgs) lib runCommand;
    inherit declInput jobsetsAttrs;
  };

  jobsetsAttrs = with pkgs.lib; mapAttrs (name: settings: recursiveUpdate defaultSettings settings) (rec {
    allvm-tools-cross = {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-pr;
      inputs.allvm-tools-src = allvm-tools;
    };
    allvm-tools-cross-next = {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-next;
      inputs.allvm-tools-src = allvm-tools;
    };
    allvm-tools-cross-cleanup = {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-cleanup;
      inputs.allvm-tools-src = allvm-tools;
    };
    allvm-tools-llvm5 = {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-pr;
      inputs.allvm-tools-src = allvm-tools.override { branch = "experimental/llvm-5"; };
      inputs.llvmVersion = { type = "nix"; value = "5"; };
    };
    allvm-tools-llvm5-next = {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-next;
      inputs.allvm-tools-src = allvm-tools.override { branch = "experimental/llvm-5"; };
      inputs.llvmVersion = { type = "nix"; value = "5"; };
    };
  });
in writeSpec
