---
name: nixvim-keymaps
description: Handles adding, changing, and verifying keymaps and which-key group labels in the Nixvim config at nixvim/ in this repo. This skill should be used when a request mentions a keybinding, a new leader group, a which-key group label, a group icon, leader-prefixed mappings, moving keymaps between config/plugins/ and languages/, or "what keys are bound to X". It encodes the which-key v3 spec format, the group-label placement rule, the icon rules, and the verification commands that actually catch breakage.
---

# Nixvim Keymaps

## Overview

`nixvim/` is a Nixvim flake whose keymaps are split across feature modules, with
every `<leader>` group label centralised in one file. Two things make edits here
error-prone: which-key v3 rejects a spec form that looks perfectly valid, and the
obvious ways to check the result are all silent about failure.

## Repo facts

- Config root: `nixvim/`. Core modules in `nixvim/config/`, per-plugin modules in
  `nixvim/config/plugins/` (imported by `config/plugins/default.nix`), per-language
  overlays in `nixvim/languages/`.
- `<leader>` is Space, set in `nixvim/config/opts.nix`.
- Packages built from the flake: `base`, `nix`, `python`.
- `nixvim/docs/keymaps.md` is a maintained reference of every binding. Any keymap or
  group change must be reflected there or the docs go stale.

## Where a change goes

| Change | File |
| --- | --- |
| A binding owned by a feature | That feature's module: `config/diagnostic.nix`, `config/lsp.nix`, `config/plugins/<plugin>.nix`, `languages/<lang>.nix` |
| Plugin enable + settings + its keymaps | `config/plugins/<plugin>.nix` |
| A **group label** for any `<leader>x` group | `config/plugins/which-keys.nix`, always |

Rule: group labels go in `which-keys.nix` and nowhere else, even when the group's
bindings live in another module. This was decided explicitly — do not put a group
label next to the feature that owns the bindings.

A group label is two things in two places, and both are required:

1. A `keymaps` entry with an empty `action` so the prefix itself is a real mapping.
2. A `plugins.which-key.settings.spec` entry that supplies `group` and `icon`.

```nix
# config/diagnostic.nix — the binding half
keymaps = [
  {
    key = "<leader>d";
    mode = "n";
    options.desc = "Diagnostic";
    action = "";
  }
];
```

```nix
# config/plugins/which-keys.nix — the label half
{
  "__unkeyed-1" = "<leader>d";
  group = "Diagnostic";
  icon = "";
  mode = "n";
}
```

## Writing the spec: `__unkeyed-N`, never a string key

which-key v3 treats *any* string field name in a spec entry that is not a known
field as a hard error. So the v1-style form fails outright:

```nix
{ ["<leader>t"] = { group = "Test"; }; }   # which-key v1 — ERROR in v3
# Invalid field `<leader>t>`
{ "<leader>t", group = "Test"; }           # list form — not writable in Nix
{ "__unkeyed-1" = "<leader>t"; group = "Test"; }   # correct
```

`__unkeyed-N` is nixvim's documented convention, shown in its `specExamples`. The
nixvim option transform rewrites `__unkeyed-N` keys into the positional list form
at build time, so the generated config is `{ "<leader>t", group = "Test", ... }`.
Quote the attribute: `"__unkeyed-1"`, not `__unkeyed-1`.

To add a mapping from the same entry, chain them: `"__unkeyed-2" = "<cmd>Foo<CR>"`.

## Icons

**which-key derives icons automatically from `desc`.** A `<leader>` group with no
spec entry still gets an icon if its description matches a built-in rule in
`which-key/icons.lua`. Existing example: the `Diagnostic` group rendered
`nf-md-list_status` purely from the rule `{ pattern = "diagnostic", ... }`.

So before assuming a group has no icon, check the built-in rules:

```bash
# locate the installed which-key, then read its auto-icon rules
ICONS="$(nvim --headless -c 'lua io.write(vim.api.nvim_get_runtime_file("lua/which-key/icons.lua", false)[1] or "")' -c 'qa!' 2>&1)"
grep -n 'pattern =\|plugin =' "$ICONS"
```

Two traps:

- **`icon = ""` is not a no-op.** Empty string is truthy in Lua, so `Icons.get`
  returns it and renders a blank instead of falling through to the auto rules. To
  get auto-derived icons, omit `icon` entirely — never set it to `""`.
- **The built-in `test` rule is dead.** It resolves `cat = "filetype", name =
  "neotest-summary"`, and nvim-web-devicons has no such filetype, so it always
  yields nothing. Test groups need an explicit icon.

Precedence, from `which-key/view.lua`: an explicit `node.mapping.icon` wins,
otherwise rules are matched against `desc`.

Several existing icons happen to coincide with a built-in rule (`Find` and `code`
both resolve to `fa-search` / `` by default), so those groups would render an icon
even without their `icon` field. Do not rely on that coincidence — keep the explicit
icon so the rendering does not change if upstream edits a rule.

Always set `icon` explicitly on a group label and verify the codepoint against the
installed font with `scripts/check_group_icons.sh`. A codepoint the font does not
cover renders as a tofu box and nothing warns about it.

## Nixvim keymap shape

```nix
{
  key = "<leader>ta";
  mode = "n";                          # or ["n" "v"]
  options.desc = "Run nearest test";
  action = "<cmd>lua require('neotest').run.run()<CR>";
}
```

`<cmd>lua require('mod').fn()<CR>` is the house style. Group-label entries use
`action = ""`. Verify plugin API names against the installed plugin source rather
than assuming; a wrong name builds cleanly and fails only when pressed.

## Formatting

`nix fmt` is broken in this repo: the git root is one level above `nixvim/`, so it
dies with `Failed! 1 error found` / `unexpected end of file`. Run alejandra directly:

```bash
cd nixvim
nix run nixpkgs#alejandra -- --check flake.nix languages/python.nix config plugins
```

Conventions: `{pkgs, ...}: {` or `_: {` arg headers, 2-space indent, flat dotted
attrs for simple settings (`plugins.lint.lintersByFt.python = ["ruff"];`), blank
line between top-level blocks.

## Verification

Run both before committing any keymap or group change:

```bash
.opencode/skills/nixvim-keymaps/scripts/check_which_key_spec.sh   # add base|nix to check other profiles
.opencode/skills/nixvim-keymaps/scripts/check_group_icons.sh
```

`check_which_key_spec.sh` builds a package, dumps the real generated config with
`nixvim-print-init`, extracts the which-key spec, and forces `Mappings.parse()` on
it. Both scripts exit non-zero on failure and have been confirmed to fail on
deliberately broken input.

**Do not trust these as validation:**

- `:checkhealth which-key` writes into the health buffer, which headless nvim never
  prints. It reports nothing regardless of whether the config is broken.
- Reading `Mappings.notifs` directly in a plain headless run. The parse is lazy, so
  it reads zero even for a broken config. Forcing `Mappings.parse()` first is what
  makes the number meaningful.

Two more traps when verifying:

- Nix flakes only see git-tracked files. A newly created module makes `nix build
  .#python` fail with `To make it visible to Nix, run: git add ...`. Either stage
  the file or build with `nix build "path:$PWD#python"`.
- `.#devShells.python` does not resolve; use `.#devShells.x86_64-linux.python`.

## Checklist

1. Put bindings in the feature's module; put the group label in
   `config/plugins/which-keys.nix`.
2. Use `"__unkeyed-1" = "<key>"` in the spec. Never a quoted string key.
3. Give the group an explicit, real `icon`; never `icon = ""`.
4. Run `check_which_key_spec.sh` and `check_group_icons.sh`.
5. Run the alejandra check.
6. Update `nixvim/docs/keymaps.md`.
7. Build the affected packages: `nix build .#base --no-link`, `.#nix`, `.#python`.

## Resources

- `scripts/check_which_key_spec.sh` — force-parse the generated which-key spec and
  report notifications. The only reliable headless check.
- `scripts/check_group_icons.sh` — verify every group icon codepoint exists in the
  installed Nerd Font, with glyph names when a cached `glyphnames.json` is present.
  Set `NERD_GLYPHNAMES=/path/to/glyphnames.json` to seed the cache.