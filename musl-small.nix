{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
  # Attributes passed to nixpkgs. Don't build packages marked as unfree.
,  nixpkgsArgs ? { config = { allowUnfree = false; inHydra = true; }; }
}:

let
  release-lib = import ./support/release-musl-native-lib.nix {
    inherit supportedSystems scrubJobs nixpkgs nixpkgsArgs;
  };
in
  with release-lib;
  with import ./support/job-groups.nix release-lib;

{
  linuxCommon = mapTestOn linuxCommon;
  small = mapTestOn small;
  compilers = mapTestOn compilers;
  misc = mapTestOn misc;

  # TODO: Simplify
  tests = (mapTestOn (packagePlatforms pkgs)).tests;
}
