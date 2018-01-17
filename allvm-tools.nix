{ nixpkgs, allvm-tools-src }:

let
  config = { allowUnfree = false; };
  lib = import (nixpkgs + "/lib");
  buildToolsFor = _: crossSystem:
    let pkgs = import nixpkgs { inherit config crossSystem; };
    in pkgs.callPackage (allvm-tools-src + "/nix/build.nix") {
      clang = pkgs.buildPackages.clang;
      buildDocs = false;
    };
  in lib.mapAttrs buildToolsFor {
    inherit (lib.systems.examples)
      musl64
      muslpi
      aarch64-multiplatform-musl
      ;
  }

