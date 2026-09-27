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

  keymaps = [
    {
      key = "gd";
      mode = "n";
      options.desc = "Definition";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
    }
    {
      key = "gD";
      mode = "n";
      options.desc = "Declaration";
      action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
    }
    {
      key = "gi";
      mode = "n";
      options.desc = "Implementations";
      action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
    }
    {
      key = "gI";
      mode = "n";
      options.desc = "Type";
      action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
    }

    {
      key = "<leader>sd";
      mode = "n";
      options.desc = "Documentation";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
    }
    {
      key = "<leader>ss";
      mode = "n";
      options.desc = "Signature";
      action = "<cmd>lua vim.lsp.buf.signature_help()<CR>";
    }

    {
      key = "<leader>fr";
      mode = "n";
      options.desc = "References";
      action = "<cmd>lua Snacks.picker.lsp_references()<CR>";
    }

    {
      key = "<leader>cr";
      mode = "n";
      options.desc = "Rename";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
    }
  ];
}
