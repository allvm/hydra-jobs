{ nixpkgs, allvm-tools-src }:

let
  config = { allowUnfree = false; };
  lib = import (nixpkgs + "/lib");
  buildToolsFor = _: crossSystem:
    let pkgs = import nixpkgs { inherit config crossSystem; };
    in pkgs.callPackage ./support/allvm-tools {
      src = allvm-tools-src;
      clang-format = pkgs.buildPackages.clang.cc;
      buildDocs = false;
      # TODO: Enable this!
      # (our cross-built LLVM's are built with full dependencies on dynamic libraries
      #  that aren't included as allowed references such as ncursesw, etc.)
      stripReferences = false;
    };
  in lib.mapAttrs buildToolsFor {
    inherit (lib.systems.examples)
      musl64
      muslpi
      aarch64-multiplatform-musl
      ;
  }

