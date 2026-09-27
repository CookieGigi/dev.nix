{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.source = inputs.nixpkgs;

  extraPackages = with pkgs; [ripgrep];

  imports = [
    ./opts.nix
    ./colorscheme.nix
    ./lsp.nix
    ./diagnostic.nix
    ./plugins
    ./keymap.nix
  ];
}
