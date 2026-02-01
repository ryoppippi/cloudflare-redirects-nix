{
  pkgs,
  cloudflareRedirectsLib ? import ../lib { inherit (pkgs) lib; },
}:
let
  inherit (pkgs) lib;
  inherit (cloudflareRedirectsLib) generateRedirects;

  testCases = [
    {
      name = "basic-redirect";
      toml = ''
        [[redirects]]
        from = "/old"
        to = "/new"
      '';
      expected = "/old /new 301";
    }
    {
      name = "redirect-with-status";
      toml = ''
        [[redirects]]
        from = "/*"
        to = "/index.html"
        status = 200
      '';
      expected = "/* /index.html 200";
    }
    {
      name = "multiple-redirects";
      toml = ''
        [[redirects]]
        from = "/a"
        to = "/b"

        [[redirects]]
        from = "/c"
        to = "/d"
        status = 302
      '';
      expected = ''
        /a /b 301
        /c /d 302'';
    }
    {
      name = "empty-redirects-array";
      toml = ''
        redirects = []
      '';
      expected = "";
    }
  ];

  runTest =
    {
      name,
      toml,
      expected,
    }:
    let
      tomlFile = pkgs.writeText "${name}.toml" toml;
      result = generateRedirects tomlFile;
    in
    pkgs.runCommand "test-redirects-${name}" { } ''
      expected=${lib.escapeShellArg expected}
      result=${lib.escapeShellArg result}

      if [ "$expected" = "$result" ]; then
        echo "PASS: ${name}"
        mkdir -p $out
        touch $out/.ok
      else
        echo "FAIL: ${name}"
        echo "Expected:"
        echo "$expected"
        echo "Got:"
        echo "$result"
        exit 1
      fi
    '';

  testDerivations = map runTest testCases;
in
pkgs.runCommand "cloudflare-redirects-tests"
  {
    passthru.tests = testDerivations;
  }
  ''
    ${lib.concatMapStringsSep "\n" (
      drv: "echo 'Checking ${drv.name}...' && test -d ${drv}"
    ) testDerivations}
    echo "All ${toString (builtins.length testDerivations)} tests passed!"
    mkdir -p $out
    touch $out/.ok
  ''
