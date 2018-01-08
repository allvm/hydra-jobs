
{ nixpkgs,
, supportedSystems ? [ "x86_64-linux" ]
}:

with import "${nixpkgs}/pkgs/top-level/release-lib.nix" { inherit supportedSystems; };

in
{
    souper = mapTestOn { souper = all; };
}
