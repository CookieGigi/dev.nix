_: {
  plugins = {
    which-key.enable = true;
  };

  imports = [
    ./formater.nix
    ./linter.nix
    ./icon.nix
    ./completion.nix
    ./treesitter.nix
    ./snacks.nix
  ];
}
