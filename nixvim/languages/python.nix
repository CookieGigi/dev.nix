{pkgs, ...}: {
  lsp.servers.basedpyright = {
    enable = true;
    package = pkgs.basedpyright;
    config = {
      cmd = [
        "basedpyright-langserver"
        "--stdio"
      ];
      filetypes = ["python"];
      root_markers = [
        "pyproject.toml"
        ".git"
      ];
      settings.basedpyright.analysis = {
        typeCheckingMode = "recommended";
        autoSearchPaths = true;
      };
    };
  };

  plugins.conform-nvim.settings.formatters_by_ft.python = ["ruff_format"];

  plugins.lint.lintersByFt.python = ["ruff"];
}
