{ nixpkgs }:

let
  d = import (nixpkgs + "/doc");
in {
  ${d.name} = d;
}
