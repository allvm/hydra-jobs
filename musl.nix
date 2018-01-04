

{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
}:

# For now, hijack release-cross.nix

with import "${nixpkgs}/pkgs/top-level/release-lib.nix" { inherit supportedSystems scrubJobs; };

let
  nativePlatforms = linux;

  common = {
    buildPackages.binutils = nativePlatforms;
    gmp = nativePlatforms;
    libcCross = nativePlatforms;
  };

  gnuCommon = lib.recursiveUpdate common {
    buildPackages.gcc = nativePlatforms;
    coreutils = nativePlatforms;
  };

  linuxCommon = lib.recursiveUpdate gnuCommon {
    buildPackages.gdb = nativePlatforms;

    bison = nativePlatforms;
    busybox = nativePlatforms;
    dropbear = nativePlatforms;
    ed = nativePlatforms;
    ncurses = nativePlatforms;
    patch = nativePlatforms;
  };

  /* Cross-built bootstrap tools for every supported platform */
  bootstrapTools = let
    tools = import ../stdenv/linux/make-bootstrap-tools-cross.nix { system = "x86_64-linux"; };
    maintainers = [ lib.maintainers.dezgeg ];
    mkBootstrapToolsJob = drv:
      assert lib.elem drv.system (supportedSystems ++ [ "aarch64-linux" ]);
      hydraJob' (lib.addMetaAttrs { inherit maintainers; } drv);
  in lib.mapAttrsRecursiveCond (as: !lib.isDerivation as) (name: mkBootstrapToolsJob) tools;
in

{


  bootstrapTools = bootstrapTools.musl;
}
