_: {
  plugins = {
    conform-nvim = {
      enable = true;
      autoInstall.enable = true;
      settings = {
        format_on_save = {
          lsp_format = "fallback";
          timeout_ms = 500;
        };
        formatters_by_ft = {};
      };
    };
  };

  keymaps = [
    {
      key = "<leader>cf";
      mode = "n";
      options.desc = "format";
      action = "<cmd>lua require('conform').format({ lsp_format = 'fallback' })<CR>";
    }
  ];
}
