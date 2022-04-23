{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    npm-build-package.url = "github:serokell/nix-npm-buildpackage";
  };
  outputs = { self, nixpkgs, flake-utils, npm-build-package }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs {
        inherit system;
        overlays = [ npm-build-package.overlay ];
      }; in
      let nodeModules = pkgs.mkNodeModules {
        src = ./.;
        pname = "my-node-modules";
        version = "0.0.0";
        packageOverrides = { };
      };
      in
      rec {
        packages.complice-xmobar =
          pkgs.stdenv.mkDerivation
            {
              name = "complice-xmobar";
              src = ./.;
              buildPhase = "cp ${./complice.js} complice.js";
              installPhase = ''
                mkdir -p $out/app
                cp -r ${nodeModules}/node_modules $out/app/node_modules
                cp complice.js $out/app
              '';
            };
      });
}
