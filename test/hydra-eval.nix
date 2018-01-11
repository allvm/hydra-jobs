{ nixpkgs, release, args ? { inherit nixpkgs; } }:
let
  lib = import "${nixpkgs}/lib";
  # hydraJobs = import "${nixpkgs}/pkgs/top-level/release.nix";
  hydraJobs = import release args //
  # Compromise: accuracy vs. resources needed for evaluation.
  { supportedSystems = cfg.systems or [ "x86_64-linux" "x86_64-darwin" ]; };
  # cfg = (import nixpkgs {}).config.rebuild-amount or {};
  cfg = { };

  recurseIntoAttrs = attrs: attrs // { recurseForDerivations = true; };

  # hydraJobs leaves recurseForDerivations as empty attrmaps;
  # that would break nix-env and we also need to recurse everywhere.
  tweak = lib.mapAttrs
  (name: val:
  if name == "recurseForDerivations" then true
  else if lib.isAttrs val && val.type or null != "derivation"
  then recurseIntoAttrs (tweak val)
  else val
  );

  # Some of these contain explicit references to platform(s) we want to avoid;
  # some even (transitively) depend on ~/.nixpkgs/config.nix (!)
  blacklist = [
    "tarball" "metrics" "manual"
    "darwin-tested" "unstable" "stdenvBootstrapTools"
    "moduleSystem" "lib-tests" # these just confuse the output
  ];

in
  tweak (builtins.removeAttrs hydraJobs blacklist)

