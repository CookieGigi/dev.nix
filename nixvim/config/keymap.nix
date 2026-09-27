_: {
  keymaps = [
    # TAB
    {
      key = "gt";
      mode = "n";
      options.desc = "next tab";
      action = "<cmd>tabnext<CR>";
    }
    {
      key = "gT";
      mode = "n";
      options.desc = "previous tab";
      action = "<cmd>tabprevious<CR>";
    }
    {
      key = "<leader>nt";
      mode = "n";
      options.desc = "Tab";
      action = "<cmd>tabnew<CR>";
    }
    {
      key = "<leader>xt";
      mode = "n";
      options.desc = "Tab";
      action = "<cmd>tabclose<CR>";
    }

    # Comments
    {
      key = "<leader>cc";
      mode = ["n" "v"];
      options.desc = "toggle comments";
      action = "<cmd>normal gcc<CR>";
    }
  ];
}
