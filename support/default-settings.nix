{ lib }:

let
  gitlab = import ./gitlab.nix { inherit lib; };
in {
  enabled = "1";
  hidden = false;
  description = "";
  input = "jobs";
  path = "default.nix";
  keep = 0;
  shares = 42;
  interval = 600;
  inputs = {
    jobs = gitlab { group = "dtz"; repo = "hydra-jobs"; };
    nixpkgs = {
      type = "git";
      value = "git://github.com/NixOS/nixpkgs";
    };
    supportedSystems = {
      type = "nix";
      value = ''[ \"x86_64-linux\" ]'';
    };
  };
  mail = false;
  mailOverride = ""; # devnull+hydra@wdtz.org";
}
