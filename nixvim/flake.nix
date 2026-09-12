{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixvim,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        system,
        pkgs,
        ...
      }: let
        nvim =
          (nixvim.lib.evalNixvim {
            inherit system;
            extraSpecialArgs = {inherit inputs;};
            modules = [./config];
          }).config.build.package;
      in {
        packages.default = nvim;
        devShells.default = pkgs.mkShell {packages = [nvim];};
      };
    };
}
