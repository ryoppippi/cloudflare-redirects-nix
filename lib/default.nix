{ lib }:
{
  generateRedirects = import ./generate-redirects.nix { inherit lib; };
  generateRedirectsFromList = import ./generate-redirects-from-list.nix { inherit lib; };
}
