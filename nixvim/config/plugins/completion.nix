_: {
  plugins = {
    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        keymap.preset = "default";
        completion = {
          accept.auto_brackets.enabled = true;
          documentation.auto_show = true;
          ghost_text.enabled = true;
        };
        signature.enabled = true;
        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "normal";
        };
        sources = {
          default = ["lsp" "path" "snippets" "buffer"];
          providers = {
            buffer = {
              score_offset = -7;
            };
            lsp = {
              fallbacks = [];
            };
          };
        };
      };
    };
  };
}
