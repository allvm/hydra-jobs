{ lib }:
let
  gitlabURL = "git@gitlab.engr.illinois.edu";
  gitlabGenURL =
    { group ? "llvm", repo, branch ? null }:
      let
        branchStr = lib.optionalString (branch != null) (" " + branch);
      in
      "${gitlabURL}:${group}/${repo}" + branchStr;
  gitspec = value: { type = "git"; inherit value; };
in lib.makeOverridable (args: gitspec (gitlabGenURL args))

