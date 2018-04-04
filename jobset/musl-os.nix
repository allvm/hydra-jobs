{ nixpkgs }:

let
  lib = import (nixpkgs + "/lib");
  localSystem.config = "x86_64-unknown-linux-musl";

  callTest = fn: args:
    import fn ({ inherit localSystem; } //args);

  nixos = nixpkgs + "/nixos";

  genTest = n: callTest (nixos + "/tests/" + n + "-musl.nix") {};

  tests = [
    "env"
    "nginx"
    "openssh"
    "sddm"
    "simple"
    "slim"
    "sudo"
    "systemd"

    #"nfs"
  ];

in lib.genAttrs tests genTest
