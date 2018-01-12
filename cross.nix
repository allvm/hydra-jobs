

{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, crossSystemExampleName ? "musl64"
, bootstrapName ? "musl"
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
}:

# For now, hijack release-lib.nix

let release-lib = import (nixpkgs + "/pkgs/top-level/release-lib.nix") { inherit supportedSystems scrubJobs; };

in
  with release-lib;
  with import ./support/job-groups.nix release-lib;

let
  /* Cross-built bootstrap tools for every supported platform */
  bootstrapTools = let
    tools = import (nixpkgs + "/pkgs/stdenv/linux/make-bootstrap-tools-cross.nix") { system = "x86_64-linux"; };
    maintainers = [ lib.maintainers.dtzWill ];
    mkBootstrapToolsJob = drv:
      assert lib.elem drv.system supportedSystems;
      hydraJob' (lib.addMetaAttrs { inherit maintainers; } drv);
  in lib.mapAttrsRecursiveCond (as: !lib.isDerivation as) (name: mkBootstrapToolsJob) tools;

  crossSystem = lib.systems.examples.${crossSystemExampleName};
  mapTOC = mapTestOnCross crossSystem;
in

{
  linuxCommon = mapTOC linuxCommon;
  small = mapTOC small;
  compilers = mapTOC compilers;

  bootstrapTools = bootstrapTools.${crossSystem.arch} or bootstrapTools.${bootstrapName};
}
