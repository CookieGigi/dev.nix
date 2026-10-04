---
name: nixvim-language
description: Adds or changes a per-language overlay in the Nixvim config at nixvim/languages/ in this repo, modelled on languages/python.nix and languages/nix.nix. This skill should be used when a request mentions adding support for a language, a new LSP server for a language, a formatter or linter for a filetype, a neotest adapter or test runner, or a new nixvim package/profile beyond base, nix and python. It encodes the four integration points every overlay must set, the flake wiring that makes an overlay live, the packages.prefix idiom for handing a language environment to an LSP, and a verification script that catches overlays which build but are never wired in.
---

# Nixvim Language Overlays

## Overview

`nixvim/languages/` holds one module per language. Each overlay is a nixvim
module that wires four things for a single language, and `nixvim/flake.nix`
composes overlays into named packages.

Two failure modes make this harder than it looks:

1. **An overlay can be perfect and still do nothing.** Nothing imports
   `languages/` automatically. `flake.nix` lists module paths explicitly, so an
   overlay that is not named there is dead code that still type-checks.
2. **A wrong attribute name fails silently.** `plugins.lint.lintersByFt` is
   freeform, so `lintersByFt.rustt` is accepted and quietly produces no linter.
   `nix build` succeeds. Nothing warns.

Verify against the config the package really generates, not against the source.

## Repo facts

- Config root: `nixvim/`. Core in `config/`, per-plugin in `config/plugins/`,
  per-language overlays in `languages/`.
- Overlays that exist: `nix.nix`, `python.nix`. Packages built: `base`, `nix`,
  `python`.
- `<leader>` is Space (`nixvim/config/opts.nix`).
- Every treesitter grammar is already installed (nixvim's
  `grammarPackages` default is `package.allGrammars`), so a new language needs
  **no** treesitter configuration. Do not add any.
- `nix fmt` is unusable in this repo. Use
  `nix run nixpkgs#alejandra -- --check flake.nix languages/<lang>.nix config plugins`.

## The four integration points

Every overlay sets these for its language. `languages/nix.nix` is the minimal
example (three of four — nix has no test runner); `languages/python.nix` is the
full one.

```nix
{pkgs, ...}: {
  # 1. LSP
  lsp.servers.<name> = {
    enable = true;
    package = pkgs.<package>;
    config = {
      cmd = ["<binary>"];
      filetypes = ["<lang>"];
      root_markers = [<marker> ".git"];
      settings.<name>.<section> = { ... };
    };
  };

  # 2. Formatter, via conform-nvim
  plugins.conform-nvim.settings.formatters_by_ft.<lang> = ["<formatter>"];

  # 3. Linter, via lint.nvim
  plugins.lint.lintersByFt.<lang> = ["<linter>"];

  # 4. Test adapter, via neotest -- only if the language has a test runner
  plugins.neotest.adapters.<lang> = {
    enable = true;
    settings = { ... };
  };
}
```

Notes that are easy to get wrong:

- The formatter key is `formatters_by_ft` (snake_case) but the linter key is
  `lintersByFt` (camelCase). They are not symmetric.
- nixvim's conform/lint options are freeform, so a typo in either key is
  accepted silently. Check the generated config, not the build result.
- Adapters are **not** part of neotest's core setup. `neotest` itself, its
  `<leader>t` keymaps, and its group label live in `config/plugins/neotest.nix`
  and `config/plugins/which-keys.nix`. Only the adapter goes here. See the
  `nixvim-keymaps` skill before touching keymaps or group labels.
- nixvim's `plugins.neotest.adapters.<name>` takes `enable`, `package`,
  `settings` — it generates the `require("neotest-<name>")` call. Do not write
  the `require` yourself.
- neotest-python's adapter method is `discover_positions`, not `positions`.
  Verify adapter method names against the installed plugin source rather than
  guessing; the adapter settings are flat keys (`runner`, `args`,
  `pytest_discover_instances`).

## Wiring it into flake.nix

An overlay does nothing until a package composes it:

```nix
rustPkg = mkNvim [
  ./languages/nix.nix
  ./languages/rust.nix
];
# ...
packages = { ... rust = rustPkg; };
```

List `./languages/nix.nix` first in every profile: it carries `nil`, which
formats the flake files you are editing while you edit them.

Add a matching `devShells.<lang>` entry for the tools the overlay names, so
they are on `PATH` in the terminal as well:

```nix
rust = pkgs.mkShell {
  packages = [ rustPkg pkgs.rust-analyzer pkgs.rustfmt ];
};
```

Name the package after the language. `check_language.sh` relies on it.

## Handing a language environment to the LSP

Some LSPs only find their toolchain when it is on `PATH`. If a server shells out
to a package that a devShell happens to provide, the server breaks whenever nvim
was launched from some other shell. Bake the environment in instead:

```nix
{pkgs, ...}: let
  pythonEnv = pkgs.python3.withPackages (ps: [ps.pytest]);
in {
  lsp.servers.basedpyright = {
    package = pkgs.basedpyright;
    packages.prefix = [pythonEnv];
    # ...
  };
}
```

This expands to `--prefix PATH` in the generated wrapper, so the env is part of
the store path rather than inherited from the launching shell. It covers
neotest and every other plugin that shells out too, not just the LSP.

Two things to get right:

- The option is **`packages.prefix`**. `lsp.servers.<name>.extraPackages` does
  not exist; top-level `extraPackages` is what nixvim *derives* from it
  (`modules/lsp/servers/default.nix` → `modules/top-level/output.nix`).
- Bind the env in a `let`, not as a top-level module attribute. A stray
  top-level `pythonEnv = ...` is an unknown nixvim option and fails the build.

Verify the prefix actually landed:

```bash
grep -n "<env-hash>" "$(readlink -f "$(nix build .#python --no-link --print-out-paths | tail -1)/bin/nvim")"
```

## Checklist

1. Create `nixvim/languages/<lang>.nix` with the four integration points.
2. Compose it into a package in `nixvim/flake.nix`, `./languages/nix.nix` first.
3. Add a `devShells.<lang>` with the tools the overlay names.
4. `git add` the new file — flakes cannot see untracked files.
5. `./.opencode/skills/nixvim-language/scripts/check_language.sh <lang>`
6. Format: `nix run nixpkgs#alejandra -- --check flake.nix languages/<lang>.nix config plugins`
7. If you added keymaps or a group label, run the `nixvim-keymaps` skill's
   scripts and update `nixvim/docs/keymaps.md`.

## Verification

`scripts/check_language.sh <language> [package]` checks the overlay exists, that
`flake.nix` imports it, that the package builds, and then greps the **generated**
`init.lua` for each of the four integration points, plus `alejandra --check`.

It reports `RESULT: PASS`/`FAIL` and exits non-zero on failure. Run it from the
repo root. Pass a second argument only if the package is not named after the
language.

Confirm the script itself still works after editing it — a check that cannot fail
is worthless. Both of these were verified to exit 1:

- An overlay present but absent from `flake.nix` → `flake.nix never imports
  ./languages/rust.nix -- the overlay is dead code`, then
  `.#rust does not build`.
- An overlay wired in but with `lintersByFt.rustt` misspelled → builds fine,
  reports `lint has no linters_by_ft entry for "rust"` and `RESULT: FAIL`.

## Adding a devShell to a downstream project

A separate flake that consumes `nixvim` gets the profile via
`nixvim.packages.<system>.<name>`; see `hello-python/flake.nix`. It cannot extend
the config further, because `nixvim/flake.nix` exposes only built packages, not
its module list. To add per-project settings, the nixvim flake would have to
export a reusable configuration — reach for that only if a second project
actually needs it.
