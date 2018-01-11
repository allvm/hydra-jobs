# From 'rebuild-amount.sh'
nixexpr() {
	cat <<-EONIX
		let
		  lib = import $1/lib;
		  hydraJobs = import $1/pkgs/top-level/release.nix
		    # Compromise: accuracy vs. resources needed for evaluation.
		    { supportedSystems = cfg.systems or [ "x86_64-linux" "x86_64-darwin" ]; };
		  cfg = (import $1 {}).config.rebuild-amount or {};

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
	EONIX
}

