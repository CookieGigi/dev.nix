# Nixvim keymap reference

Add `keymaps` alongside `diagnostic.settings`, `lsp`, or `plugins` in the appropriate config module. Each entry uses a mode, a key, a command string as `action`, and an optional description. `<leader>` is Space in `config/opts.nix`.

## Diagnostics

| Action | Nixvim `action` |
| --- | --- |
| Show diagnostics at the cursor | `"<cmd>lua vim.diagnostic.open_float()<CR>"` |
| Next diagnostic | `"<cmd>lua vim.diagnostic.jump({ count = 1 })<CR>"` |
| Previous diagnostic | `"<cmd>lua vim.diagnostic.jump({ count = -1 })<CR>"` |
| Next error only | `"<cmd>lua vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })<CR>"` |
| Current buffer's diagnostics in location list | `"<cmd>lua vim.diagnostic.setloclist()<CR>"` |
| All diagnostics in quickfix list | `"<cmd>lua vim.diagnostic.setqflist()<CR>"` |
| Toggle diagnostics globally | `"<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>"` |
| Toggle diagnostics for the current buffer | `"<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled({ bufnr = 0 }), { bufnr = 0 })<CR>"` |

Neovim already maps `]d` and `[d` to next and previous diagnostic, and `<C-w>d` to the diagnostic float.

## LSP

| Action | Nixvim `action` |
| --- | --- |
| Go to definition | `"<cmd>lua vim.lsp.buf.definition()<CR>"` |
| Go to declaration | `"<cmd>lua vim.lsp.buf.declaration()<CR>"` |
| Go to implementation | `"<cmd>lua vim.lsp.buf.implementation()<CR>"` |
| Go to type definition | `"<cmd>lua vim.lsp.buf.type_definition()<CR>"` |
| Find references | `"<cmd>lua vim.lsp.buf.references()<CR>"` |
| Show hover documentation | `"<cmd>lua vim.lsp.buf.hover()<CR>"` |
| Show signature help | `"<cmd>lua vim.lsp.buf.signature_help()<CR>"` |
| Rename symbol | `"<cmd>lua vim.lsp.buf.rename()<CR>"` |
| Code actions | `"<cmd>lua vim.lsp.buf.code_action()<CR>"` |
| Format buffer | `"<cmd>lua vim.lsp.buf.format()<CR>"` |
| Document symbols | `"<cmd>lua vim.lsp.buf.document_symbol()<CR>"` |
| Workspace symbols | `"<cmd>lua vim.lsp.buf.workspace_symbol()<CR>"` |
| Incoming calls | `"<cmd>lua vim.lsp.buf.incoming_calls()<CR>"` |
| Outgoing calls | `"<cmd>lua vim.lsp.buf.outgoing_calls()<CR>"` |
| Run code lens | `"<cmd>lua vim.lsp.codelens.run()<CR>"` |
| Refresh code lenses | `"<cmd>lua vim.lsp.codelens.refresh()<CR>"` |
| Toggle inlay hints in current buffer | `"<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })<CR>"` |
| Restart LSP clients attached to current buffer | `"<cmd>lsp restart<CR>"` |

Neovim already maps `K` to hover, `grn` to rename, `grr` to references, `gra` to code actions, `gO` to document symbols, and `grx` to run a code lens. LSP actions require an attached server that supports the corresponding feature; this config enables `nil_ls` for Nix files.

## Plugin keymaps

These bindings are defined in `config/plugins/actions.nix`, `config/plugins/snacks.nix`, and `config/plugins/which-keys.nix`:

| Key | Mode | Action | Source |
| --- | --- | --- | --- |
| `<leader>ca` | Normal | Preview and choose an LSP code action | actions-preview |
| `<leader>ff` | Normal | Find files | Snacks |
| `<leader>fg` | Normal | Live grep | Snacks |
| `<leader>gg` | Normal | Open Lazygit | Snacks |
| `<leader>g` | Normal | Git group label, no command | `which-keys.nix` |
| `g` | Normal | Go to group label, no command | `which-keys.nix` |
| `<leader>s` | Normal | Show group label, no command | `which-keys.nix` |
| `<leader>f` | Normal | Find group label, no command | `which-keys.nix` |
| `<leader>c` | Normal | Code group label, no command | `which-keys.nix` |

The group-label entries have `action = ""`; they do not invoke a plugin command.

### actions-preview

The plugin exposes one action to invoke, `require('actions-preview').code_actions(opts)`. Its `setup(opts)` function configures the plugin; it is not a separate picker command. These are Nixvim `action` strings for the supported uses:

| Action | Nixvim `action` |
| --- | --- |
| Preview and select a code action (mapped to `<leader>ca` in Normal mode) | `"<cmd>lua require('actions-preview').code_actions()<CR>"` |
| Only quick fixes | `"<cmd>lua require('actions-preview').code_actions({ context = { only = { 'quickfix' } } })<CR>"` |
| Only refactor actions | `"<cmd>lua require('actions-preview').code_actions({ context = { only = { 'refactor' } } })<CR>"` |
| Only source actions | `"<cmd>lua require('actions-preview').code_actions({ context = { only = { 'source' } } })<CR>"` |
| Apply directly if exactly one action is available | `"<cmd>lua require('actions-preview').code_actions({ apply = true })<CR>"` |

`code_actions()` also supports Visual mode, but the current `<leader>ca` mapping is Normal mode only. To use a selection, add a Visual-mode mapping with the same action. Actions require an attached LSP server that supports code actions. Preview may not be available for server actions implemented as commands rather than text edits.

### blink.cmp default preset

`config/plugins/completion.nix` selects the `default` preset. Its built-in completion keys are not Nixvim `keymaps` entries:

| Key | Action |
| --- | --- |
| `<C-Space>` | Show completion or toggle its documentation |
| `<C-e>` | Cancel completion |
| `<C-y>` | Select and accept a completion |
| `<Up>` / `<C-p>` | Previous completion |
| `<Down>` / `<C-n>` | Next completion |
| `<C-b>` / `<C-f>` | Scroll documentation up/down |
| `<Tab>` / `<S-Tab>` | Move forward/backward through snippet placeholders |
| `<C-k>` | Show or hide signature help |

These keys use fallbacks where appropriate, so their behavior depends on whether completion or a snippet is active.

### Optional plugin actions

The following actions can be mapped but are not defined as keymaps in `config/plugins/`:

| Plugin | Action | Nixvim `action` |
| --- | --- | --- |
| Snacks | Open picker menu | `"<cmd>lua Snacks.picker()<CR>"` |
| Snacks | Find open buffers | `"<cmd>lua Snacks.picker.buffers()<CR>"` |
| Snacks | Find recent files | `"<cmd>lua Snacks.picker.recent()<CR>"` |
| Snacks | Find Git files | `"<cmd>lua Snacks.picker.git_files()<CR>"` |
| Snacks | Search current-buffer lines | `"<cmd>lua Snacks.picker.lines()<CR>"` |
| Snacks | Search the word under cursor | `"<cmd>lua Snacks.picker.grep_word()<CR>"` |
| Snacks | Search open buffers | `"<cmd>lua Snacks.picker.grep_buffers()<CR>"` |
| Snacks | Show all diagnostics | `"<cmd>lua Snacks.picker.diagnostics()<CR>"` |
| Snacks | Show current-buffer diagnostics | `"<cmd>lua Snacks.picker.diagnostics_buffer()<CR>"` |
| Snacks | Browse keymaps | `"<cmd>lua Snacks.picker.keymaps()<CR>"` |
| Snacks | Browse help | `"<cmd>lua Snacks.picker.help()<CR>"` |
| Snacks | Browse Git status | `"<cmd>lua Snacks.picker.git_status()<CR>"` |
| Snacks | Browse Git branches | `"<cmd>lua Snacks.picker.git_branches()<CR>"` |
| Snacks | Browse Git log | `"<cmd>lua Snacks.picker.git_log()<CR>"` |
| Snacks | Resume last picker | `"<cmd>lua Snacks.picker.resume()<CR>"` |
| Conform | Format current buffer | `"<cmd>lua require('conform').format({ lsp_format = 'fallback' })<CR>"` |
| Conform | Show formatter information | `"<cmd>ConformInfo<CR>"` |
| nvim-lint | Run configured linters now | `"<cmd>lua require('lint').try_lint()<CR>"` |
| Treesitter | Inspect syntax under cursor | `"<cmd>Inspect<CR>"` |
| Treesitter | Open syntax tree inspector | `"<cmd>InspectTree<CR>"` |
| which-key | Show available keymaps | `"<cmd>lua require('which-key').show()<CR>"` |

Conform already formats on save, and nvim-lint already runs on `BufWritePost` and `InsertLeave`. `web-devicons` supplies icons, not a command to map; Treesitter highlighting and indentation are automatic. Snacks has additional picker sources beyond those listed here.

## Built-in Neovim commands

Common core actions you can map without adding a plugin. These are examples, not every Neovim Ex command. In the tables, `Default key` means Neovim already provides that Normal-mode key; a custom mapping is optional and may override an existing key.

### Files and buffers

| Action | Nixvim `action` | Default key |
| --- | --- | --- |
| Save current file | `"<cmd>write<CR>"` | `:w` |
| Save all modified files | `"<cmd>wall<CR>"` | `:wa` |
| Quit current window | `"<cmd>quit<CR>"` | `:q` |
| Save and quit | `"<cmd>wq<CR>"` | `:wq` |
| Quit all windows | `"<cmd>qall<CR>"` | `:qa` |
| Close current buffer | `"<cmd>bdelete<CR>"` | `:bd` |
| List buffers | `"<cmd>ls<CR>"` | `:ls` |
| Next buffer | `"<cmd>bnext<CR>"` | `:bn` |
| Previous buffer | `"<cmd>bprevious<CR>"` | `:bp` |
| Alternate buffer | `"<cmd>buffer #<CR>"` | `<C-^>` |
| Create empty buffer | `"<cmd>enew<CR>"` | `:enew` |
| Reload current file from disk | `"<cmd>edit<CR>"` | `:e` |
| Open file under cursor | `"gf"` | `gf` |

Commands such as `:bdelete`, `:quit`, and `:edit` may refuse to run if they would discard unsaved changes. Avoid adding `!` unless you intend to discard them.

### Windows and tabs

| Action | Nixvim `action` | Default key |
| --- | --- | --- |
| Horizontal split | `"<cmd>split<CR>"` | `<C-w>s` |
| Vertical split | `"<cmd>vsplit<CR>"` | `<C-w>v` |
| Close window | `"<cmd>close<CR>"` | `<C-w>c` |
| Keep only current window | `"<cmd>only<CR>"` | `<C-w>o` |
| Focus left window | `"<C-w>h"` | `<C-w>h` |
| Focus lower window | `"<C-w>j"` | `<C-w>j` |
| Focus upper window | `"<C-w>k"` | `<C-w>k` |
| Focus right window | `"<C-w>l"` | `<C-w>l` |
| Focus next window | `"<C-w>w"` | `<C-w>w` |
| Equalize window sizes | `"<C-w>="` | `<C-w>=` |
| New tab | `"<cmd>tabnew<CR>"` | `:tabnew` |
| Next tab | `"<cmd>tabnext<CR>"` | `gt` |
| Previous tab | `"<cmd>tabprevious<CR>"` | `gT` |
| Close tab | `"<cmd>tabclose<CR>"` | `:tabclose` |

### Search, navigation, and lists

| Action | Nixvim `action` | Default key |
| --- | --- | --- |
| Search forward (enter a pattern) | `"/"` | `/` |
| Search backward (enter a pattern) | `"?"` | `?` |
| Next search match | `"n"` | `n` |
| Previous search match | `"N"` | `N` |
| Search word under cursor forward | `"*"` | `*` |
| Search word under cursor backward | `"#"` | `#` |
| Clear search highlighting | `"<cmd>nohlsearch<CR>"` | `:noh` |
| Go to start of file | `"gg"` | `gg` |
| Go to end of file | `"G"` | `G` |
| Jump backward | `"<C-o>"` | `<C-o>` |
| Jump forward | `"<C-i>"` | `<C-i>` |
| Open quickfix list | `"<cmd>copen<CR>"` | `:copen` |
| Close quickfix list | `"<cmd>cclose<CR>"` | `:cclose` |
| Next quickfix item | `"<cmd>cnext<CR>"` | `:cnext` |
| Previous quickfix item | `"<cmd>cprevious<CR>"` | `:cprevious` |
| Open location list | `"<cmd>lopen<CR>"` | `:lopen` |
| Next location-list item | `"<cmd>lnext<CR>"` | `:lnext` |
| Previous location-list item | `"<cmd>lprevious<CR>"` | `:lprevious` |

### Editing and display

| Action | Nixvim `action` | Default key |
| --- | --- | --- |
| Undo | `"u"` | `u` |
| Redo | `"<C-r>"` | `<C-r>` |
| Repeat last change | `"."` | `.` |
| Toggle comment on current line | `"<cmd>normal gcc<CR>"` | `gcc` |
| Delete current line | `"dd"` | `dd` |
| Yank current line | `"yy"` | `yy` |
| Paste after cursor | `"p"` | `p` |
| Reindent current line | `"=="` | `==` |
| Indent current line right | `">>"` | `>>` |
| Indent current line left | `"<<"` | `<<` |
| Toggle current fold | `"za"` | `za` |
| Open all folds | `"zR"` | `zR` |
| Close all folds | `"zM"` | `zM` |
| Toggle line wrapping | `"<cmd>set wrap!<CR>"` | `:set wrap!` |
| Toggle visible whitespace | `"<cmd>set list!<CR>"` | `:set list!` |
| Open terminal in current window | `"<cmd>terminal<CR>"` | `:terminal` |
| Open help for word under cursor | `"<cmd>help <C-r><C-w><CR>"` | `:help {topic}` |

`gc{motion}` toggles comments over a motion (for example, `gcip` for a paragraph), and `gc` toggles comments on a Visual selection. These built-in mappings use the buffer's `commentstring`; no comment plugin is needed. For a new keymap, `:normal gcc` expands the built-in mapping, while a plain `"gcc"` action may not because Nixvim mappings are non-recursive by default.

For Normal-mode commands such as `"dd"` or `"<C-w>h"`, use the key sequence directly as `action` rather than wrapping it in `<cmd>...<CR>`. The `:help` action above inserts the word under the cursor into the Ex command line.

## Example

Use the same `keymaps` syntax in either config module. For example, in `config/lsp.nix`:

```nix
_: {
  lsp = {
    # Existing LSP configuration goes here.
  };

  keymaps = [
    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      options.desc = "Go to definition";
    }
    {
      mode = "n";
      key = "<leader>lr";
      action = "<cmd>lsp restart<CR>";
      options.desc = "Restart LSP";
    }
  ];
}
```

This configuration sets `<leader>` to Space in `config/opts.nix`, so `Space l r` runs `:lsp restart`.

For a plugin action, put a `keymaps` block alongside `plugins`, not inside the individual plugin settings. For example, in `config/plugins/formater.nix`:

```nix
keymaps = [
  {
    mode = "n";
    key = "<leader>cf";
    action = "<cmd>lua require('conform').format({ lsp_format = 'fallback' })<CR>";
    options.desc = "Format buffer";
  }
];
```

References: [Neovim quick reference](https://neovim.io/doc/user/quickref/), [Neovim diagnostics](https://neovim.io/doc/user/diagnostic/), [Neovim LSP](https://neovim.io/doc/user/lsp/), [actions-preview](https://github.com/aznhe21/actions-preview.nvim), [Snacks picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md), [blink.cmp presets](https://github.com/Saghen/blink.cmp/blob/main/lua/blink/cmp/keymap/presets.lua), [Conform](https://github.com/stevearc/conform.nvim), [nvim-lint](https://github.com/mfussenegger/nvim-lint), and [which-key](https://github.com/folke/which-key.nvim).
