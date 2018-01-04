{ lib }:
  let
    gitlabURL = "git@gitlab.engr.illinois.edu";
    gitlabGenURL =
      { group ? "llvm", repo, branch ? null }:
        let
          branchStr = lib.optionalString (branch != null) (" " + branch);
        in
        "${gitlabURL}:${group}/${repo}" + branchStr;
    in args: lib.makeOverridable (a: { type = "git"; value = gitlabGenURL a; }) args

