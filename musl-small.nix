{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
  # Attributes passed to nixpkgs. Don't build packages marked as unfree.
,  nixpkgsArgs ? { config = { allowUnfree = false; inHydra = true; }; }
}:

let release-musl-native-lib = import ./release-musl-native-lib.nix { inherit supportedSystems scrubJobs nixpkgs nixpkgsArgs; };

in
  with release-musl-native-lib;
  with import ./job-groups.nix release-musl-native-lib;

{
  linuxCommon = mapTestOn linuxCommon;
  small = mapTestOn small;
  compilers = mapTestOn compilers;
}
