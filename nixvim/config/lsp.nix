_: {
  lsp = {
    codelens.enable = true;
    inlayHints.enable = true;

    servers = {
      nil_ls = {
        enable = true;
        config = {
          cmd = ["nil"];
          filetypes = ["nix"];
          root_markers = ["flake.nix" ".git"];
        };
      };
    };
  };
}
