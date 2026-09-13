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
      linters = {
        statix = {
          cmd = "statix";
          args = [
            "check"
            "-i"
            "--stdin"
          ];
          stdin = true;
        };
        deadnix = {
          cmd = "deadnix";
          args = ["-"];
          stdin = true;
        };
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
}
