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
      value = "git://github.com/allvm/hydra-jobs.git";
    };
    supportedSystems = {
      type = "nix";
      value = ''[ \"x86_64-linux\" ]'';
    };
  };
  mail = false;
  mailOverride = ""; # devnull+hydra@wdtz.org";
}
