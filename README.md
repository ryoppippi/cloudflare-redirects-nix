# cloudflare-redirects-nix

Nix library to generate Cloudflare `_redirects` file from TOML or Nix lists.

## Usage

### Add to your flake inputs

```nix
{
  inputs = {
    cloudflare-redirects.url = "github:ryoppippi/cloudflare-redirects-nix";
  };
}
```

### Option 1: Define redirects in Nix (recommended)

Define redirects directly in your `flake.nix`:

```nix
{
  outputs = { nixpkgs, cloudflare-redirects, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit (cloudflare-redirects.lib) generateRedirectsFromList;

      redirects = [
        { from = "/*"; to = "/index.html"; status = 200; }
        { from = "/old-page"; to = "/new-page"; }  # status defaults to 301
      ];
    in
    {
      packages.default = pkgs.stdenvNoCC.mkDerivation {
        # ...
        installPhase = ''
          mkdir -p $out
          echo '${generateRedirectsFromList redirects}' > $out/_redirects
        '';
      };
    };
}
```

### Option 2: Use a TOML file

Create a `redirects.toml`:

```toml
[[redirects]]
from = "/*"
to = "/index.html"
status = 200

[[redirects]]
from = "/old-page"
to = "/new-page"
# status defaults to 301
```

Then use it in your derivation:

```nix
{
  outputs = { nixpkgs, cloudflare-redirects, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit (cloudflare-redirects.lib) generateRedirects;
    in
    {
      packages.default = pkgs.stdenvNoCC.mkDerivation {
        # ...
        installPhase = ''
          mkdir -p $out
          echo '${generateRedirects ./redirects.toml}' > $out/_redirects
        '';
      };
    };
}
```

Both options generate the following `_redirects` file:

```
/* /index.html 200
/old-page /new-page 301
```

## Redirect Format

Each redirect entry supports:

| Field    | Required | Default | Description                |
| -------- | -------- | ------- | -------------------------- |
| `from`   | Yes      | -       | Source path (supports `*`) |
| `to`     | Yes      | -       | Destination path or URL    |
| `status` | No       | `301`   | HTTP status code           |

## API

| Function                    | Description                            |
| --------------------------- | -------------------------------------- |
| `generateRedirectsFromList` | Generate `_redirects` from a Nix list  |
| `generateRedirects`         | Generate `_redirects` from a TOML file |

## Running Tests

```bash
nix flake check
```

## Licence

MIT
