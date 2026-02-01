{ lib }:
tomlPath:
let
  redirectsToml = lib.importTOML tomlPath;

  formatRedirect =
    r:
    let
      status = if r ? status then toString r.status else "301";
    in
    "${r.from} ${r.to} ${status}";

  lines = map formatRedirect redirectsToml.redirects;
in
lib.concatStringsSep "\n" lines
