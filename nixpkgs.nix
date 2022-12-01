let
  rev = "93ea1dbdb0e7c7d295b2755244c4ebe80626aac2";
  nixpkgs = builtins.fetchTarball {
    name = "nixpkgs-${rev}";
    url = "https://github.com/nixos/nixpkgs/archive/${rev}.tar.gz";
    sha256 = "sha256:01wci2ijw2l29972lc1bh2zbg7lbs1qzy3xrxasjd5n183iqjvlj";
  };
in
import nixpkgs
