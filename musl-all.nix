

{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
  # Attributes passed to nixpkgs. Don't build packages marked as unfree.
,  nixpkgsArgs ? { config = { allowUnfree = false; inHydra = true; }; }
}:

# For now, hijack release-cross.nix

with import "${nixpkgs}/pkgs/top-level/release-lib.nix" { inherit supportedSystems scrubJobs nixpkgsArgs; };

mapTestOnCross lib.systems.examples.musl64 ((packagePlatforms pkgs) // rec {
      haskell.compiler = packagePlatforms pkgs.haskell.compiler;
      haskellPackages = packagePlatforms pkgs.haskellPackages;

      # Language packages disabled in https://github.com/NixOS/nixpkgs/commit/ccd1029f58a3bb9eca32d81bf3f33cb4be25cc66

      #emacsPackagesNg = packagePlatforms pkgs.emacsPackagesNg;
      #rPackages = packagePlatforms pkgs.rPackages;
      ocamlPackages = { };
      perlPackages = { };

      darwin = packagePlatforms pkgs.darwin // {
        cf-private = {};
        osx_private_sdk = {};
        xcode = {};
      };
    } )
