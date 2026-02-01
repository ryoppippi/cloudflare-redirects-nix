{ lib }:
redirects:
let
  formatRedirect = import ./format-redirect.nix { inherit lib; };
  lines = map formatRedirect redirects;
in
lib.concatStringsSep "\n" lines
