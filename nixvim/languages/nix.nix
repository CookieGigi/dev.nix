{pkgs, ...}: {
  lsp.servers.nil_ls = {
    enable = true;
    package = pkgs.nil;
    config = {
      cmd = ["nil"];
      filetypes = ["nix"];
      root_markers = [
        "flake.nix"
        ".git"
      ];
    };
  };

  plugins.conform-nvim.settings.formatters_by_ft.nix = ["alejandra"];

  plugins.lint.lintersByFt.nix = [
    "statix"
    "deadnix"
  ];
}
