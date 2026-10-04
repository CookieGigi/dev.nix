#!/usr/bin/env bash
# Validate the which-key spec that this config actually generates.
#
# Why this exists: `:checkhealth which-key` and a plain `Mappings.notifs`
# read both report zero problems for a spec that is completely broken.
# checkhealth writes into the health buffer, which headless nvim never
# prints, and the spec parse is lazy so nothing has been parsed yet when
# you read notifs. The only reliable headless check is to load the
# generated spec and force Mappings.parse() on it.
#
# Usage: scripts/check_which_key_spec.sh [package]
#   package defaults to python; use base or nix to check other profiles.

set -euo pipefail

PKG="${1:-python}"
NIXVIM_DIR="${NIXVIM_DIR:-/home/cookiegigi/Projects/DEV/nixvim}"
INIT=/tmp/nixvim-keymaps-init.lua
SPEC=/tmp/nixvim-keymaps-spec.lua
CHECK=/tmp/nixvim-keymaps-check.lua

cd "$NIXVIM_DIR"

echo "==> building .#$PKG"
# New files are invisible to the flake until they are git-added. If this
# fails with "To make it visible to Nix, run: git add ...", stage the file
# or build with "nix build path:$PWD#$PKG" instead.
OUT="$(nix build ".#$PKG" --no-link --print-out-paths 2>/dev/null | tail -1)"
NVIM="$OUT/bin/nvim"

echo "==> dumping generated init.lua"
"$OUT/bin/nixvim-print-init" > "$INIT"

# The spec table is the first entry of require("which-key").setup({...}).
# Entries sit at 8 spaces and the table closes at 4, so stop there rather
# than running to EOF.
awk '
  /require\("which-key"\)\.setup/ { inwk = 1 }
  inwk && /^[[:space:]]*spec = \{/ { inspec = 1; next }
  inspec && /^    \},$/ { exit }
  inspec { print }
' "$INIT" > "$SPEC.body"

if ! grep -q 'group = ' "$SPEC.body"; then
  echo "!! could not locate the which-key spec table in $INIT" >&2
  exit 1
fi

{ echo "return {"; cat "$SPEC.body"; echo "}"; } > "$SPEC"

cat > "$CHECK" <<'LUA'
local Mappings = require("which-key.mappings")
local spec = assert(loadfile("/tmp/nixvim-keymaps-spec.lua"))()

print(string.format("  %d spec entries", #spec))
for i, s in ipairs(spec) do
  print(string.format("  [%d] %s", i, (vim.inspect(s):gsub("%s+", " "))))
end

Mappings.parse(spec)
print(string.format("  notifs: %d", #Mappings.notifs))
for _, n in ipairs(Mappings.notifs) do
  print(string.format("  level=%s msg=%s", tostring(n.level), n.msg))
end

print(#Mappings.notifs == 0 and "RESULT: PASS" or "RESULT: FAIL")
if #Mappings.notifs ~= 0 then
  vim.cmd("cq")
end
vim.cmd("qa!")
LUA

echo "==> checking spec"
"$NVIM" --headless -l "$CHECK"