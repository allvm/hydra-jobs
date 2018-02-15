{ nixpkgs, allvm-tools-src, llvmVersion ? 4 }:

let
  config = { allowUnfree = false; };
  lib = import (nixpkgs + "/lib");
  examples = lib.systems.examples // { musl32 = { config = "i686-unknown-linux-musl"; }; };
  getLLVMPkgs = pkgs: pkgs."llvmPackages_${toString llvmVersion}";
  buildALLVMWith = pkgs: pkgs.callPackage ../support/allvm-tools {
    inherit (getLLVMPkgs pkgs) llvm lld;
    src = allvm-tools-src;
    clang-format = (getLLVMPkgs pkgs.buildPackages).clang.cc;
    buildDocs = true;
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
    inherit (examples)
      aarch64-multiplatform-musl
      musl64
      musl32
      muslpi
      # openwrt-ar71xx
      ;
  };
  allvm-tools-native = lib.mapAttrs buildToolsOn {
    inherit (examples) musl64 musl32;
    #default = null;
  };
}
