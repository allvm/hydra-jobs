{ nixpkgs, allvm-tools-src, llvmVersion ? 4 }:

let
  config = { allowUnfree = false; };
  lib = import (nixpkgs + "/lib");
  buildALLVMWith = pkgs: pkgs.callPackage ./support/allvm-tools {
    inherit (pkgs."llvmPackages_${toString llvmVersion}") llvm lld;
    src = allvm-tools-src;
    clang-format = pkgs.buildPackages."clang_${toString llvmVersion}".cc;
    buildDocs = false;
    # TODO: Enable this!
    # (our cross-built LLVM's are built with full dependencies on dynamic libraries
    #  that aren't included as allowed references such as ncursesw, etc.)
    stripReferences = false;
  };

  buildToolsFor = _: crossSystem:
    buildALLVMWith (import nixpkgs { inherit config crossSystem; });
  buildToolsOn = _: localSystem:
    buildALLVMWith (import nixpkgs { inherit config localSystem; });

in {
  allvm-tools-cross = lib.mapAttrs buildToolsFor {
    inherit (lib.systems.examples)
      aarch64-multiplatform-musl
      musl64
      muslpi
      openwrt-ar71xx
      ;
  };
  allvm-tools-native = lib.mapAttrs buildToolsOn {
    inherit (lib.systems.examples) musl64;
    #default = null;
  };
}
