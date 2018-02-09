{ lib }:

let
  gitlab = import ./gitlab.nix { inherit lib; };
in rec {
  ## Git repo definitions, aliases
  allvm = gitlab { repo = "allvm-nixpkgs"; };
  nixpkgs-musl = allvm.override { branch = "feature/musl"; };
  nixpkgs-musl-cleanup = allvm.override { branch = "feature/musl-cleanup"; };
  nixpkgs-musl-pr = {
    type = "git";
    value = "https://github.com/dtzWill/nixpkgs feature/musl";
  };
  nixpkgs-musl-next = {
    type = "git";
    value = "https://github.com/dtzWill/nixpkgs feature/musl-next";
  };

  allvm-tools = gitlab { repo = "allvm"; };
  allvm-analysis = allvm-tools.override { branch = "experimental/allplay"; };
}
