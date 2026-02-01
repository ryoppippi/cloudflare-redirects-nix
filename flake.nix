{
  description = "Nix library to generate Cloudflare _redirects from TOML or Nix lists";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      nixpkgs,
      git-hooks,
      treefmt-nix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      treefmtEval =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };
          settings.formatter.oxfmt = {
            command = "${pkgs.oxfmt}/bin/oxfmt";
            includes = [
              "*.md"
              "*.yml"
              "*.yaml"
              "*.json"
              "*.jsonc"
              "*.toml"
            ];
            excludes = [ ];
          };
        };
    in
    {
      lib = import ./lib { inherit (nixpkgs) lib; };

      formatter = forAllSystems (system: (treefmtEval system).config.build.wrapper);

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              treefmt = {
                enable = true;
                entry = "${(treefmtEval system).config.build.wrapper}/bin/treefmt --fail-on-change --no-cache";
                pass_filenames = false;
              };
            };
          };
        in
        {
          inherit pre-commit-check;

          default = pkgs.callPackage ./test { };

          formatting = (treefmtEval system).config.build.check ./.;

          typos =
            pkgs.runCommand "check-typos"
              {
                nativeBuildInputs = [ pkgs.typos ];
                src = ./.;
              }
              ''
                cd $src
                typos
                touch $out
              '';
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              treefmt = {
                enable = true;
                entry = "${(treefmtEval system).config.build.wrapper}/bin/treefmt --fail-on-change --no-cache";
                pass_filenames = false;
              };
            };
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              typos-lsp
              nixd
            ];
            shellHook = ''
              ${pre-commit-check.shellHook}
            '';
          };
        }
      );
    };
}
