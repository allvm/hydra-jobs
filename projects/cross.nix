{ nixpkgs ? <nixpkgs>, declInput ? {} }:

let
  pkgs = import nixpkgs {};
  gitlab = import ../support/gitlab.nix { inherit (pkgs) lib; };
  defaultSettings = {
    enabled = "1";
    hidden = false;
    description = "";
    input = "jobs";
    path = "default.nix";
    keep = 0;
    shares = 42;
    interval = 300;
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
  };

  ## Git repo definitions, aliases
  allvm = gitlab { repo = "allvm-nixpkgs"; };
  allvm-tools = gitlab { repo = "allvm"; };
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

  ## Jobset generation
  crossJobset = crossSystemExampleName: nixpkgs_repo: {
    path = "jobset/cross.nix";
    inputs.crossSystemExampleName = { type = "string"; value = crossSystemExampleName; };
    inputs.nixpkgs = nixpkgs_repo;
  };
  crossMuslJobs = name: repo: {
    "cross-musl64-${name}" = crossJobset "musl64" repo;
    "cross-musl32-${name}" = crossJobset "musl32" repo;
    "cross-muslpi-${name}" = crossJobset "muslpi" repo;
    "cross-aarch64-${name}" = crossJobset "aarch64-multiplatform-musl" repo;
  };
  nativeJobs = name: repo: {
    "native-small-musl64-${name}" = {
      path = "jobset/musl-small.nix";
      inputs.nixpkgs = repo;
    };
    "native-misc-musl64-${name}" = {
      path = "jobset/musl-misc.nix";
      inputs.nixpkgs = repo;
    };
  };
  jobsFor = name: repo:
    (crossMuslJobs name repo) // (nativeJobs name repo);

  jobsetsAttrs = with pkgs.lib; mapAttrs (name: settings: recursiveUpdate defaultSettings settings) (
    {}
    // (jobsFor "old" nixpkgs-musl)
    // (jobsFor "cleanup" nixpkgs-musl-cleanup)
    // (jobsFor "PR" nixpkgs-musl-pr)
    // (jobsFor "next" nixpkgs-musl-next)
    // rec {
    #bootstrap-tools = {
    #  keep = 2;
    #  input = "nixpkgs";
    #  path = "pkgs/stdenv/linux/make-bootstrap-tools.nix";
    #};


    cross-mingwW64 = {
      path = "jobset/cross.nix";
      enabled = "0";
      inputs.crossSystemExampleName = { type = "string"; value = "mingwW64"; };
      inputs.nixpkgs = nixpkgs-musl;
    };

    # =====================================================
    allvm-tools-cross= {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-pr;
      inputs.allvm-tools-src = allvm-tools;
    };
    allvm-tools-cross-next = {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-next;
      inputs.allvm-tools-src = allvm-tools;
    };
    allvm-tools-cross-cleanup = {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-cleanup;
      inputs.allvm-tools-src = allvm-tools;
    };
    allvm-tools-llvm5 = {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-pr;
      inputs.allvm-tools-src = allvm-tools.override { branch = "experimental/llvm-5"; };
      inputs.llvmVersion = { type = "nix"; value = "5"; };
    };
    allvm-tools-llvm5-next = {
      path = "jobset/allvm-tools.nix";
      inputs.nixpkgs = nixpkgs-musl-next;
      inputs.allvm-tools-src = allvm-tools.override { branch = "experimental/llvm-5"; };
      inputs.llvmVersion = { type = "nix"; value = "5"; };
    };

    nixpkgs-manual = {
      path = "jobset/manual.nix";
      enabled = "0";
    };

    nixpkgs-manual-musl = {
      path = "jobset/manual.nix";
      enabled = "0";
      inputs.nixpkgs = nixpkgs-musl;
    };

  });
  fileContents = with pkgs.lib; ''
    cat <<EOF
    ${builtins.toXML declInput}
    EOF
    cat > $out <<EOF
    {
      ${concatStringsSep "," (mapAttrsToList (name: settings: ''
        "${name}": {
            "enabled": ${settings.enabled},
            "hidden": ${if settings.hidden then "true" else "false"},
            "description": "${settings.description}",
            "nixexprinput": "${settings.input}",
            "nixexprpath": "${settings.path}",
            "checkinterval": ${toString settings.interval},
            "schedulingshares": ${toString settings.shares},
            "enableemail": ${if settings.mail then "true" else "false"},
            "emailoverride": "${settings.mailOverride}",
            "keepnr": ${toString settings.keep},
            "inputs": {
              ${concatStringsSep "," (mapAttrsToList (inputName: inputSettings: ''
                "${inputName}": { "type": "${inputSettings.type}", "value": "${inputSettings.value}", "emailresponsible": false }
              '') settings.inputs)}
            }
        }
      '') jobsetsAttrs)}
    }
    EOF
  '';
in {
  jobsets = pkgs.runCommand "spec.json" {} fileContents;
}
