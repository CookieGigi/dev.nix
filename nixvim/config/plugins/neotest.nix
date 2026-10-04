_: {
  plugins = {
    neotest = {
      enable = true;

      settings = {
        output.open_on_run = false;
        quickfix.open = false;
        status.virtual_text = true;
      };
    };

    which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>t";
        group = "Test";
        icon = "";
        mode = "n";
      }
    ];
  };

  keymaps = [
    {
      key = "<leader>ta";
      mode = "n";
      options.desc = "Run nearest test";
      action = "<cmd>lua require('neotest').run.run()<CR>";
    }
    {
      key = "<leader>tf";
      mode = "n";
      options.desc = "Run test file";
      action = "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>";
    }
    {
      key = "<leader>td";
      mode = "n";
      options.desc = "Run test directory";
      action = "<cmd>lua require('neotest').run.run(vim.fn.getcwd())<CR>";
    }
    {
      key = "<leader>tr";
      mode = "n";
      options.desc = "Run last test";
      action = "<cmd>lua require('neotest').run.run_last()<CR>";
    }
    {
      key = "<leader>ts";
      mode = "n";
      options.desc = "Toggle test summary";
      action = "<cmd>lua require('neotest').summary.toggle()<CR>";
    }
    {
      key = "<leader>to";
      mode = "n";
      options.desc = "Show test output";
      action = "<cmd>lua require('neotest').output.open({ enter = true })<CR>";
    }
    {
      key = "<leader>tw";
      mode = "n";
      options.desc = "Toggle test watch";
      action = "<cmd>lua require('neotest').watch.toggle()<CR>";
    }
  ];
}
