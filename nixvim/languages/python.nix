{pkgs, ...}: let
  # basedpyright resolves imports from PATH when `autoSearchPaths` is on, so
  # prefixing this env bakes `pytest` into the generated wrapper's PATH and the
  # LSP keeps working no matter which shell launched nvim. `packages.prefix`
  # (not `extraPackages`) is the per-server option; the top-level
  # `extraPackages` is what nixvim derives from it.
  pythonEnv = pkgs.python3.withPackages (ps: [ps.pytest]);
in {
  lsp.servers.basedpyright = {
    enable = true;
    package = pkgs.basedpyright;
    packages.prefix = [pythonEnv];
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
