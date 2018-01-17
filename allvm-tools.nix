{ nixpkgs, allvm-tools-src, crossSystemExampleName ? null }:

let
  config = { allowUnfree = false; };
  crossSystem = if crossSystemExampleName == null then null
                else (import nixpkgs + "/lib").systems.examples.${crossSystemExampleName};
  pkgs = import nixpkgs {
    inherit config crossSystem;
  };
in pkgs.callPackage (allvm-tools-src + "/nix/build.nix") {
  clang = pkgs.buildPackages.clang;
  buildDocs = false;
}

