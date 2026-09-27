{lib, ...}: {
  plugins = {
    # Lint (linters)
    lint = {
      enable = true;
      autoInstall.enable = true;
      lintersByFt = {
        nix = [
          "statix"
          "deadnix"
        ];
      };
      autoCmd = {
        event = [
          "BufWritePost"
          "InsertLeave"
        ];
        callback = lib.nixvim.mkRaw ''
          function()
            require('lint').try_lint()
          end
        '';
      };
    };
  };

  keymaps = [
    {
      key = "<leader>cl";
      mode = "n";
      options.desc = "Lint buffer";
      action = "<cmd>lua require('lint').try_lint()<CR>";
    }
  ];
}
