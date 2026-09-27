_: {
  plugins = {
    actions-preview = {
      enable = true;
    };
  };

  keymaps = [
    {
      key = "<leader>ca";
      mode = "n";
      options.desc = "Action";
      action = "<cmd>lua require('actions-preview').code_actions()<CR>";
    }
  ];
}
