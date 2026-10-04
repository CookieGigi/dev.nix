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

  # neotest itself is configured in config/plugins/neotest.nix; only the adapter
  # is language specific.
  plugins.neotest.adapters.python = {
    enable = true;
    settings = {
      runner = "pytest";
      args = [
        "-p"
        "no:cacheprovider"
      ];
      pytest_discover_instances = true;
    };
  };
}
