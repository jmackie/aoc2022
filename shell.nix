let pkgs = import ./nixpkgs.nix { }; in
pkgs.mkShell {
  nativeBuildInputs = with pkgs.buildPackages; [
    erlang
    # julia is broken on aarch64-darwin :(
    racket
  ];
}
