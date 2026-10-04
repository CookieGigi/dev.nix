#!/usr/bin/env bash
# Verify that a language overlay in nixvim/languages/ is actually wired up.
#
# Why this exists: adding a file to nixvim/languages/ does nothing on its own.
# Nothing imports that directory automatically -- flake.nix lists the module
# paths explicitly -- so an overlay can sit there looking perfect while the
# built package contains none of it. This checks the four integration points
# against the config the package really generates, not against the source.
#
# Usage: scripts/check_language.sh <language> [package]
#   language is the overlay basename, e.g. python for languages/python.nix
#   package defaults to the language name; pass it explicitly if the flake
#   names the profile differently.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: $(basename "$0") <language> [package]" >&2
  exit 2
fi

LANG="$1"
PKG="${2:-$LANG}"
NIXVIM_DIR="${NIXVIM_DIR:-/home/cookiegigi/Projects/DEV/nixvim}"
INIT=/tmp/nixvim-language-init.lua
FAILURES=0

cd "$NIXVIM_DIR"

fail() {
  echo "  MISSING  $1"
  FAILURES=$((FAILURES + 1))
}

pass() {
  echo "  ok       $1"
}

echo "==> source: languages/$LANG.nix"
if [ ! -f "languages/$LANG.nix" ]; then
  echo "  MISSING  languages/$LANG.nix does not exist" >&2
  exit 1
fi
pass "languages/$LANG.nix exists"

echo "==> flake wiring"
# flake.nix composes each profile from an explicit module list. An overlay
# that is not named there is dead code.
if grep -q "\./languages/$LANG\.nix" flake.nix; then
  pass "flake.nix imports ./languages/$LANG.nix"
else
  fail "flake.nix never imports ./languages/$LANG.nix -- the overlay is dead code"
fi

echo "==> building .#$PKG"
# `|| true` because `set -o pipefail` would otherwise abort here and hide the
# real reason the build failed.
OUT="$(nix build ".#$PKG" --no-link --print-out-paths 2>/dev/null | tail -1 || true)"
if [ -z "$OUT" ]; then
  fail ".#$PKG does not build -- add a package to flake.nix that composes languages/$LANG.nix"
  echo
  echo "RESULT: FAIL ($FAILURES problem(s))"
  exit 1
fi
pass "$OUT"

echo "==> dumping generated init.lua"
"$OUT/bin/nixvim-print-init" > "$INIT"

# Each check below greps the generated config, so it fails if the option was
# renamed, misspelled, or silently dropped by the module system.

# 1. LSP: nixvim emits vim.lsp.config("<name>", { ... filetypes = { "<lang>" } })
#    followed by vim.lsp.enable("<name>").
if grep -q 'filetypes = {[^}]*"'"$LANG"'"' "$INIT"; then
  pass "an LSP server claims the \"$LANG\" filetype"
else
  fail "no enabled LSP server lists \"$LANG\" in filetypes"
fi

# 2. conform: formatters_by_ft = { <lang> = { ... } }
if grep -q 'formatters_by_ft = {.*'"$LANG"' = {' "$INIT"; then
  pass "conform has a formatters_by_ft entry for \"$LANG\""
else
  fail "conform has no formatters_by_ft entry for \"$LANG\""
fi

# 3. lint: __lint.linters_by_ft = { <lang> = { ... } }
if grep -q 'linters_by_ft = {.*'"$LANG"' = {' "$INIT"; then
  pass "lint has a linters_by_ft entry for \"$LANG\""
else
  fail "lint has no linters_by_ft entry for \"$LANG\""
fi

# 4. neotest: the adapter is optional, so report it rather than failing.
#    nixvim emits require("neotest-<adapter>")({ ... }) inside the setup call.
if grep -q 'require("neotest'"$LANG"'")\|require("neotest-'"$LANG"'")' "$INIT"; then
  pass "a neotest adapter is registered for \"$LANG\""
else
  echo "  note     no neotest adapter for \"$LANG\" (fine if the language has no runner)"
fi

echo "==> formatting"
# `nix fmt` is unusable in this repo, so call alejandra with explicit paths.
if nix run nixpkgs#alejandra -- --check "languages/$LANG.nix" flake.nix > /dev/null 2>&1; then
  pass "alejandra --check is clean"
else
  fail "alejandra --check rejected languages/$LANG.nix or flake.nix"
fi

echo
if [ "$FAILURES" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL ($FAILURES problem(s))"
  exit 1
fi
