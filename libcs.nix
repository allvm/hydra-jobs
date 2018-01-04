

{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
}:

# For now, hijack release-cross.nix

let
  cross = import "${nixpkgs}/pkgs/top-level/release-cross.nix" { inherit supportedSystems scrubJobs; };
in

{
  inherit (cross) musl uclibc;

  bootstrapTools = {
    inherit (bootstrapTools) musl uclibc;
  };
}
