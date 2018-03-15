{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
  # Attributes passed to nixpkgs. Don't build packages marked as unfree.
,  nixpkgsArgs ? { config = { allowUnfree = false; inHydra = true; }; }
}:


let
  lib = import (nixpkgs + "/lib");
  muslNixpkgsArgs = lib.recursiveUpdate { localSystem = lib.systems.examples.musl64; } nixpkgsArgs;
  packageSet = import nixpkgs;
in with lib;

rec {
  allPackages = args: packageSet (lib.recursiveUpdate args muslNixpkgsArgs);

  hydraJob' = if scrubJobs then hydraJob else id;

  # pkgs = packageSet (lib.recursiveUpdate { system = "x86_64-linux"; config.allowUnsupportedSystem = true; } nixpkgsArgs);
  pkgs = allPackages { config.allowUnsupportedSystems = true; };
  inherit lib;

  pkgsFor = system:
    if system == "x86_64-linux" then pkgs #  pkgs_x86_64_linux
    # else if system == "i686-linux" then pkgs_i686_linux
    # else if system == "aarch64-linux" then pkgs_aarch64_linux
    # else if system == "armv6l-linux" then pkgs_armv6l_linux
    # else if system == "armv7l-linux" then pkgs_armv7l_linux
    # else if system == "x86_64-darwin" then pkgs_x86_64_darwin
    # else if system == "x86_64-freebsd" then pkgs_x86_64_freebsd
    # else if system == "i686-freebsd" then pkgs_i686_freebsd
    # else if system == "i686-cygwin" then pkgs_i686_cygwin
    # else if system == "x86_64-cygwin" then pkgs_x86_64_cygwin
    else abort "unsupported system type: ${system}";


  forAllSupportedSystems = systems: f:
    genAttrs (filter (x: elem x supportedSystems) systems) f;

  # testOn = systems: f: hydraJob' (f pkgs);
  /* Build a package on the given set of platforms.  The function `f'
     is called for each supported platform with Nixpkgs for that
     platform as an argument .  We return an attribute set containing
     a derivation for each supported platform, i.e. ‘{ x86_64-linux =
     f pkgs_x86_64_linux; i686-linux = f pkgs_i686_linux; ... }’. */
  testOn = systems: f: forAllSupportedSystems systems
    (system: hydraJob' (f (pkgsFor system)));


  /* Similar to the testOn function, but with an additional
     'crossSystem' parameter for allPackages, defining the target
     platform for cross builds. */
     #  testOnCross = crossSystem: systems: f: forAllSupportedSystems systems
     #    (system: hydraJob' (f (allPackages { inherit system crossSystem; })));


  /* Given a nested set where the leaf nodes are lists of platforms,
     map each leaf node to `testOn [platforms...] (pkgs:
     pkgs.<attrPath>)'. */
  mapTestOn = mapAttrsRecursive
    (path: systems: testOn systems (pkgs: getAttrFromPath path pkgs));

  /* Recursively map a (nested) set of derivations to an isomorphic
     set of meta.platforms values. */
  packagePlatforms = mapAttrs (name: value:
    let res = builtins.tryEval (
      if isDerivation value then
        value.meta.hydraPlatforms or (value.meta.platforms or [ "x86_64-linux" ])
      else if value.recurseForDerivations or false || value.recurseForRelease or false then
        packagePlatforms value
      else
        []);
    in if res.success then res.value else []
    );


  /* Common platform groups on which to test packages. */
  inherit (platforms) unix linux darwin cygwin all mesaPlatforms;

  /* Platform groups for specific kinds of applications. */
  x11Supported = linux;
  gtkSupported = linux;
  ghcSupported = linux;
}

