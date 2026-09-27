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
    lazygit
  ];

  keymaps = [
    {
      key = "<leader>ff";
      action = "<cmd>lua Snacks.picker.files()<cr>";
      mode = "n";
      options.desc = "Files";
    }
    {
      key = "<leader>fg";
      action = "<cmd>lua Snacks.picker.grep()<cr>";
      mode = "n";
      options.desc = "Grep";
    }
    {
      key = "<leader>g";
      mode = "n";
      options.desc = "Git";
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
