_: {
  plugins = {
    which-key = {
      enable = true;
      settings.triggers = [
        {
          "__unkeyed-1" = "<leader>";
          mode = ["n" "v"];
        }
      ];
      settings.spec = [
        {
          "__unkeyed-1" = "g";
          group = "Go to";
          icon = "󰁔";
          mode = "n";
        }
        {
          "__unkeyed-1" = "<leader>s";
          group = "Show";
          icon = "󰈈";
          mode = "n";
        }
        {
          "__unkeyed-1" = "<leader>f";
          group = "Find";
          icon = "";
          mode = "n";
        }
        {
          "__unkeyed-1" = "<leader>c";
          group = "Code";
          icon = "";
          mode = "n";
        }
        {
          "__unkeyed-1" = "<leader>d";
          group = "Diagnostic";
          icon = "";
          mode = "n";
        }
        {
          "__unkeyed-1" = "<leader>t";
          group = "Test";
          icon = "󱖫";
          mode = "n";
        }
        {
          "__unkeyed-1" = "<leader>n";
          group = "New";
          icon = "";
          mode = "n";
        }
        {
          "__unkeyed-1" = "<leader>x";
          group = "Close";
          icon = "󰅖";
          mode = "n";
        }
      ];
    };
  };

  keymaps = [
    {
      key = "<leader>?";
      mode = "n";
      options.desc = "List of keys";
      action = "<cmd>lua require('which-key').show()<CR>";
    }
  ];
}
