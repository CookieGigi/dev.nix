{
  description = "Mini Python project for testing the Nixvim python profile";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixvim = {
      url = "path:../nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixvim,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = nixvim.packages.${system}.python;

    devShells.${system}.default = pkgs.mkShell {
      packages = [
        nixvim.packages.${system}.python
        pkgs.python3
        pkgs.ruff
        pkgs.basedpyright
      ];
    };
  };
}
