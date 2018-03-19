

{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, crossSystemExampleName ? "musl64"
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
}:

# For now, hijack release-lib.nix

let release-lib = import (nixpkgs + "/pkgs/top-level/release-lib.nix") { inherit supportedSystems scrubJobs; };

in
  with release-lib;
  with import ../support/job-groups.nix release-lib;

let
  crossSystem = lib.systems.examples.${crossSystemExampleName};

  bootstrapTools = let
    tools = import (nixpkgs + "/pkgs/stdenv/linux/make-bootstrap-tools.nix") { inherit crossSystem; };
    maintainers = [ lib.maintainers.dtzWill ];
    mkBootstrapToolsJob = drv:
      assert lib.elem drv.system supportedSystems;
      hydraJob' (lib.addMetaAttrs { inherit maintainers; } drv);
  in lib.mapAttrsRecursiveCond (as: !lib.isDerivation as) (name: mkBootstrapToolsJob) tools;

  mapTOC = mapTestOnCross crossSystem;
in

{
  linuxCommon = mapTOC linuxCommon;
  small = mapTOC small;
  compilers = mapTOC compilers;
  misc = mapTOC misc;

  tests = (mapTOC (packagePlatforms pkgs)).tests;

  inherit bootstrapTools;
}
