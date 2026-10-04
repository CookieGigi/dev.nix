{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nvim.url = "path:./nixvim";
  };

  outputs = {
    flake-parts,
    nvim,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        system,
        pkgs,
        ...
      }: {
        devShells = {
          default = pkgs.mkShell {
            packages = [
              nvim.packages.${system}.default
            ];
          };
          python = pkgs.mkShell {
            packages = [
              nvim.packages.${system}.python
            ];
          };
        };

        formatter = pkgs.alejandra;
      };
    };
}
