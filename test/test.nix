#  nix-build eval-release-test.nix --arg release ./musl-all.nix --arg nixpkgs '(fetchGit ~/musl-nix)' --arg args '{ nixpkgs = fetchGit ~/musl-nix; }'

{ nixpkgs ? fetchGit ~/musl-nix, release ? ../musl-all.nix, args ? { inherit nixpkgs; } }:

# import ./hydra-eval.nix { inherit nixpkgs release args; }
import ./eval-release-test.nix {
  inherit nixpkgs release args;
}
