_: {
  plugins = {
    snacks = {
      enable = true;
      settings = {
        picker = {
          enabled = true;
        };
        lazygit = {
          enabled = true;
        };
      };
    };
  };

  keymaps = [
    {
      key = "<leader>f";
      mode = "n";
      options.desc = "find";
    }
    {
      key = "<leader>ff";
      action = "<cmd>lua Snacks.picker.files()<cr>";
      mode = "n";
      options.desc = "Find files";
    }
    {
      key = "<leader>fg";
      action = "<cmd>lua Snacks.picker.grep()<cr>";
      mode = "n";
      options.desc = "Live grep";
    }
    {
      key = "<leader>gg";
      action = "<cmd>lua Snacks.lazygit()<cr>";
      mode = "n";
      options.desc = "Lazygit";
    }
  ];
}
