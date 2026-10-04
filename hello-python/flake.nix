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
        # neotest-python runs `pytest` through the interpreter found on PATH
        (pkgs.python3.withPackages (ps: [ps.pytest]))
        pkgs.ruff
        pkgs.basedpyright
      ];
    };
  };
}
