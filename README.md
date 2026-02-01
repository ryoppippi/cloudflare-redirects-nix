# cloudflare-redirects-nix

Nix library to generate Cloudflare `_redirects` file from TOML.

## Usage

### Add to your flake inputs

```nix
{
  inputs = {
    cloudflare-redirects.url = "github:ryoppippi/cloudflare-redirects-nix";
  };
}
```

### Create a `redirects.toml`

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

This generates the following `_redirects` file:

```
/* /index.html 200
/old-page /new-page 301
```

### Use in your derivation

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

## TOML Format

Each redirect entry supports:

| Field    | Required | Default | Description                |
| -------- | -------- | ------- | -------------------------- |
| `from`   | Yes      | -       | Source path (supports `*`) |
| `to`     | Yes      | -       | Destination path or URL    |
| `status` | No       | `301`   | HTTP status code           |

## Running Tests

```bash
nix flake check
```

## Licence

MIT
