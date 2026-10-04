# AGENTS.md -- Projects/DEV

## Scope

This repo holds two independent flakes:

- `nixvim/` -- nixvim configuration. Packages: `base`, `nix`, `python`.
- `hello-python/` -- fixture project with deliberately broken lint/type errors.

`<leader>` is Space (`nixvim/config/opts.nix`).

## Agent Rules

- **Never modify global or system configuration without explaining first and asking.** This means `~/nixos/**`, `~/.config/opencode/**`, and anything else outside this repo. Present the diagnosis, the evidence, the exact proposed diff, and the tradeoffs, then wait for a decision. Never make the edit first and mention it afterwards.

- **Verify a diagnosis before acting on it.** Do not change configuration in response to an error until the error has been reproduced and its cause confirmed by running the real command or reading the real source. Do not infer behaviour from memory or from an earlier summary.

- **Never run `sudo nixos-rebuild`** without explicit permission for that specific run.

- Nix flakes only see git-tracked files. A new file makes `nix build .#x` fail with "To make it visible to Nix, run: git add" -- use `nix build "path:$PWD#x"` until it is staged.

- `.#devShells.python` does not resolve; use `.#devShells.x86_64-linux.python`.

## Formatting

`nix fmt` must be given an explicit path. Bare `nix fmt` passes no file arguments to
Alejandra, which then reads stdin, hits EOF, and fails with:

```
Failed! 1 error found at:
- <anonymous file on stdin>: unexpected end of file
```

Always run it as `nix fmt .` (or with explicit paths) from the directory being formatted.
`nix fmt` walks *up* from the cwd to locate the flake, so running it from `nixvim/`
correctly resolves the repo-root `flake.nix`.

To check without writing:

```bash
cd nixvim && nix run nixpkgs#alejandra -- --check flake.nix languages/python.nix config plugins
```

## Neovim / which-key

- which-key v3 rejects any string field name outside its known-fields table. Use
  `"__unkeyed-N" = "<leader>x";`, never `{ ["<leader>x"] = ...; }` (that is which-key v1).
- Do not trust `:checkhealth which-key` under headless nvim; it writes to a buffer that
  is never printed. Use `.opencode/skills/nixvim-keymaps/scripts/check_which_key_spec.sh`.
- A group label needs both halves: a `keymaps` entry with `action = ""` in the feature
  module, and a `which-key.settings.spec` entry with `group` + `icon`. All group labels
  live in `nixvim/config/plugins/which-keys.nix`.
- `icon = ""` is not a no-op -- empty string is truthy in Lua and renders a blank
  instead of falling through to which-key's auto-derivation rules. Omit `icon` instead.
- Keymap changes require updating `nixvim/docs/keymaps.md`.