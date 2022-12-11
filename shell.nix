let pkgs = import ./nixpkgs.nix { }; in
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
  ];
}
