{
  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    git-ignore-nix.url = github:IvanMalison/gitignore.nix/master;
  };
  outputs = { self, flake-utils, nixpkgs, git-ignore-nix }:
  let
    overlay = final: prev: {
      haskellPackages = prev.haskellPackages.override (old: {
        overrides = prev.lib.composeExtensions (old.overrides or (_: _: {}))
        (hself: hsuper: {
          X11-xft =
            hself.callCabal2nix "X11-xft" (git-ignore-nix.gitIgnoreSource ./.) { };
        });
      });
    };
    overlays = [ overlay ];
  in flake-utils.lib.eachDefaultSystem (system:
  let pkgs = import nixpkgs { inherit system overlays; };
  in
  rec {
    devShell = pkgs.haskellPackages.shellFor {
      packages = p: [ p.X11-xft ];
      nativeBuildInputs = [ pkgs.cabal-install ];
    };
    defaultPackage = pkgs.haskellPackages.X11-xft;
  }) // { inherit overlay overlays; } ;
}
