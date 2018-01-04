{ nixpkgs ? <nixpkgs>, declInput ? {} }:

let
  pkgs = import nixpkgs {};
  gitlab = import ./gitlab.nix { inherit (pkgs) lib; };
  defaultSettings = {
    enabled = "1";
    hidden = false;
    description = "";
    input = "jobs";
    path = "default.nix";
    keep = 1;
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
    bootstrap-tools = {
      keep = 2;
      input = "nixpkgs";
      path = "pkgs/stdenv/linux/make-bootstrap-tools.nix";
    };

    # TODO: Don't use allvm-nixpkgs repo for these
    cross-musl64 = {
      path = "pkgs/top-level/release-cross.nix";
      input = "nixpkgs";
      inputs.nixpkgs = allvm.override { branch = "experimental/cross-musl"; };
    };
    cross-musl64-ben = {
      path = "pkgs/top-level/release-cross.nix";
      input = "nixpkgs";
      inputs.nixpkgs = allvm.override { branch = "experimental/cross-musl-plus-ben"; };
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
      input = "nixpkgs";
      path = "doc/default.nix";
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
