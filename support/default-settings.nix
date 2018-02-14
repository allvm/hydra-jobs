{
  enabled = "1";
  hidden = false;
  description = "";
  input = "jobs";
  path = "default.nix";
  keep = 0;
  shares = 42;
  interval = 600;
  inputs = {
    jobs = {
      type = "git";
      value = "https://github.com/allvm/hydra-declarative";
    };
    supportedSystems = {
      type = "nix";
      value = ''[ \"x86_64-linux\" ]'';
    };
  };
  mail = false;
  mailOverride = ""; # devnull+hydra@wdtz.org";
}
