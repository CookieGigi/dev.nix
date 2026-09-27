{pkgs, ...}: {
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

  extraPackages = with pkgs; [
    fd
  ];

  keymaps = [
    {
      key = "<leader>f";
      mode = "n";
      options.desc = "find";
      action = "";
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
      key = "<leader>g";
      mode = "n";
      options.desc = "git";
      action = "";
    }
    {
      key = "<leader>gg";
      action = "<cmd>lua Snacks.lazygit()<cr>";
      mode = "n";
      options.desc = "Lazygit";
    }
  ];
}
