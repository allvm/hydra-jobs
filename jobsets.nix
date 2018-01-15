{ nixpkgs ? <nixpkgs>, declInput ? {} }:

let
  pkgs = import nixpkgs {};
  gitlab = import ./support/gitlab.nix { inherit (pkgs) lib; };
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
  allvm = gitlab { repo = "allvm-nixpkgs"; };
  allvm-tools = gitlab { repo = "allvm"; };
  jobsetsAttrs = with pkgs.lib; mapAttrs (name: settings: recursiveUpdate defaultSettings settings) (rec {
    #bootstrap-tools = {
    #  keep = 2;
    #  input = "nixpkgs";
    #  path = "pkgs/stdenv/linux/make-bootstrap-tools.nix";
    #};

    # TODO: Don't use allvm-nixpkgs repo for these
    cross-musl64 = {
      path = "cross.nix";
      inputs.crossSystemExampleName = { type = "string"; value = "musl64"; };
      inputs.nixpkgs = allvm.override { branch = "experimental/cross-musl"; };
    };
    cross-musl64-basics = {
      path = "cross.nix";
      inputs.crossSystemExampleName = { type = "string"; value = "musl64"; };
      inputs.nixpkgs = allvm.override { branch = "feature/musl-basics"; };
    };
    cross-musl64-more = {
      path = "cross.nix";
      inputs.crossSystemExampleName = { type = "string"; value = "musl64"; };
      inputs.nixpkgs = allvm.override { branch = "feature/musl"; };
    };
    cross-musl64-ben = {
      path = "cross.nix";
      inputs.crossSystemExampleName = { type = "string"; value = "musl64"; };
      inputs.nixpkgs = allvm.override { branch = "experimental/cross-musl-plus-ben"; };
    };

    cross-rpi-master = {
      path = "cross.nix";
      inputs.crossSystemExampleName = { type = "string"; value = "raspberryPi"; };
      inputs.nixpkgs = {
        type = "git";
        value = "https://github.com/dtzWill/nixpkgs";
      };
    };
    cross-rpi-wip = {
      path = "cross.nix";
      inputs.crossSystemExampleName = { type = "string"; value = "raspberryPi"; };
      inputs.nixpkgs = {
        type = "git";
        value = "https://github.com/dtzWill/nixpkgs fix/cross-low-impact";
      };
    };
    cross-muslpi = {
      path = "cross.nix";
      inputs.crossSystemExampleName = { type = "string"; value = "muslpi"; };
      inputs.bootstrapName = { type = "string"; value = "armv6l-musl"; };
      inputs.nixpkgs = allvm.override { branch = "feature/musl"; };
    };

    cross-mingwW64 = {
      path = "cross.nix";
      enabled = "0";
      inputs.crossSystemExampleName = { type = "string"; value = "mingwW64"; };
      inputs.nixpkgs = {
        type = "git";
        value = "https://github.com/dtzWill/nixpkgs fix/cross-low-impact";
      };
    };

    musl64-native = {
      path = "musl-all.nix";
      enabled = "0";
      inputs.nixpkgs = allvm.override { branch = "feature/musl"; };
    };
    musl64-native-small = {
      path = "musl-small.nix";
      inputs.nixpkgs = allvm.override { branch = "feature/musl"; };
    };
    musl64-native-misc = {
      path = "musl-misc.nix";
      inputs.nixpkgs = allvm.override { branch = "feature/musl"; };
    };

    custom-ld-default = {
      path = "custom-ld.nix";
      enabled = "0";
      inputs.nixpkgs = {
        type = "git";
        value = "https://github.com/dtzWill/nixpkgs feature/binutils-custom-ld";
      };
    };
    custom-ld-gold = {
      path = "custom-ld.nix";
      enabled = "0";
      inputs.nixpkgs = {
        type = "git";
        value = "https://github.com/dtzWill/nixpkgs feature/binutils-custom-ld";
      };
      inputs.defaultLd = { type = "string"; value = "gold"; };
    };

    /*
    hydra-jobs-master = {
      keep = 3;
      shares = 420;
    };
    hydra-jobs-production = recursiveUpdate hydra-jobs-master {
      inputs.nixpkgs.value = "${defaultSettings.inputs.nixpkgs.value} production";
    };
    */
    nixpkgs-manual = {
      path = "manual.nix";
      enabled = "0";
    };

    nixpkgs-manual-musl = {
      path = "manual.nix";
      enabled = "0";
      inputs.nixpkgs = allvm.override { branch = "feature/musl"; };
    };

    #hydra-jobs-arm = {
    #  path = "arm.nix";
    #  inputs = {
    #    nixpkgs = {
    #      value = "${defaultSettings.inputs.nixpkgs.value} hydra-arm";
    #    };
    #    supportedSystems = {
    #      value = ''[ \"armv7l-linux\" ]'';
    #    };
    #  };
    #};
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
