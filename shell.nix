let pkgs = import ./nixpkgs.nix { }; in
pkgs.mkShell {
  nativeBuildInputs = with pkgs.buildPackages; [
    erlang
  ];
}
