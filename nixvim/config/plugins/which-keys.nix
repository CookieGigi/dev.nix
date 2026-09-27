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
    };
  };

  keymaps = [
    {
      key = "g";
      mode = "n";
      options.desc = "Go to";
      action = "";
    }
    {
      key = "<leader>s";
      mode = "n";
      options.desc = "Show";
      action = "";
    }
    {
      key = "<leader>f";
      mode = "n";
      options.desc = "Find";
      action = "";
    }
    {
      key = "<leader>c";
      mode = "n";
      options.desc = "Code";
      action = "";
    }
    {
      key = "<leader>n";
      mode = "n";
      options.desc = "New";
      action = "";
    }
    {
      key = "<leader>x";
      mode = "n";
      options.desc = "Close";
      action = "";
    }
  ];
}
