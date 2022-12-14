let

  pkgs = import ./nixpkgs.nix { };

  easy-ps = import
    (pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-purescript-nix";
      rev = "7a4cb3cd6ca53566ea1675692eab0aa13907ff09";
      sha256 = "sha256-5KkyNpPakv4xIP2ba0S5GX+dcmd3AcO9kPhwa482BbA=";
    })
    {
      inherit pkgs;
    };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs.buildPackages; [
    erlang
    # julia is broken on aarch64-darwin :(
    racket
    lua5_3
    ocaml-ng.ocamlPackages_4_14.ocaml
    R
    python311
    ruby
    dart
    scala
    easy-ps.purs
    easy-ps.spago
    elixir
  ];
}
