{ lib }:
{
  generateRedirects = import ./generate-redirects.nix { inherit lib; };
}
