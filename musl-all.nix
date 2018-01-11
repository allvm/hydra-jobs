

{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
  # Attributes passed to nixpkgs. Don't build packages marked as unfree.
,  nixpkgsArgs ? { config = { allowUnfree = false; inHydra = true; }; }
}:


let
  lib = import "${nixpkgs}/lib";
  muslNixpkgsArgs = lib.recursiveUpdate { localSystem = lib.systems.examples.musl64; } nixpkgsArgs;
  packageSet = import nixpkgs;
in with lib;

with let
in rec {
  allPackages = args: packageSet (args // muslNixpkgsArgs);

  hydraJob' = if scrubJobs then hydraJob else id;

  # pkgs = packageSet (lib.recursiveUpdate { system = "x86_64-linux"; config.allowUnsupportedSystem = true; } nixpkgsArgs);
  pkgs = allPackages { };
  inherit lib;


  forAllSupportedSystems = systems: f:
    genAttrs (filter (x: elem x supportedSystems) systems) f;

  testOn = systems: f: builtins.trace systems f pkgs;
    #  /* Build a package on the given set of platforms.  The function `f'
    #     is called for each supported platform with Nixpkgs for that
    #     platform as an argument .  We return an attribute set containing
    #     a derivation for each supported platform, i.e. ‘{ x86_64-linux =
    #     f pkgs_x86_64_linux; i686-linux = f pkgs_i686_linux; ... }’. */
    #  testOn = systems: f: forAllSupportedSystems systems
    #    (system: hydraJob' (f (pkgsFor system)));


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

};

mapTestOn ((packagePlatforms pkgs) // rec {
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
