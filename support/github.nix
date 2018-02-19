{ lib }:
let
  genURL = { owner, repo, branch ? null, deepClone ? false }:
    assert deepClone -> branch != null;
    {
      type = "git";
      value = "https://github.com/${owner}/${repo}"
        + lib.optionalString (branch != null) (" " + branch)
        + lib.optionalString deepClone " 1";
    };
 in lib.makeOverridable (args: genURL args)
