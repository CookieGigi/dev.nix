_: {
  diagnostic.settings = {
    virtual_text = true;
    signs = true;
    underline = true;
    update_in_insert = false;
    severity_sort = true;
    float = {
      border = "rounded";
      source = "if_many";
    };
  };

  keymaps = [
    {
      key = "<leader>d";
      mode = "n";
      options.desc = "Diagnostic";
      action = "";
    }
    {
      key = "<leader>du";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      mode = "n";
      options.desc = "Under cursor";
    }
    {
      key = "<leader>db";
      action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
      mode = "n";
      options.desc = "Buffer";
    }
    {
      key = "<leader>dg";
      action = "<cmd>lua vim.diagnostic.setqflist()<CR>";
      mode = "n";
      options.desc = "Global";
    }
    {
      key = "<leader>dt";
      action = "<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>";
      mode = "n";
      options.desc = "Toggle";
    }
  ];
}
