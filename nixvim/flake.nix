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
        mkNvim = extraModules:
          (nixvim.lib.evalNixvim {
            inherit system;
            extraSpecialArgs = {inherit inputs;};
            modules = [./config] ++ extraModules;
          }).config.build.package;

        basePkg = mkNvim [];
        nixPkg = mkNvim [./languages/nix.nix];
        pythonPkg = mkNvim [
          ./languages/nix.nix
          ./languages/python.nix
        ];
      in {
        packages = {
          base = basePkg;
          default = nixPkg;
          nix = nixPkg;
          python = pythonPkg;
        };

        devShells = {
          default = pkgs.mkShell {packages = [nixPkg];};
          python = pkgs.mkShell {
            packages = [
              pythonPkg
              pkgs.python3
              pkgs.ruff
              pkgs.basedpyright
            ];
          };
        };

        formatter = pkgs.alejandra;
      };
    };
}
