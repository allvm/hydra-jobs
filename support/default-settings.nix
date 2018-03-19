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
      value = "https://github.com/allvm/hydra-jobs";
    };
    supportedSystems = {
      type = "nix";
      value = ''[ \"x86_64-linux\" \"i686-linux\" ]'';
    };
  };
  mail = false;
  mailOverride = ""; # devnull+hydra@wdtz.org";
}
