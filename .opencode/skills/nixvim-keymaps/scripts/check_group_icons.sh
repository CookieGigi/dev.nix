#!/usr/bin/env bash
# Verify every which-key group icon in config/plugins/which-keys.nix is a real
# glyph in the installed Nerd Font.
#
# Why this exists: a Nerd Font codepoint that the installed font does not
# cover renders as a tofu box, and nothing in the build or in which-key
# complains. The failure is only visible in the popup. This checks the
# codepoint against fontconfig so a bad pick is caught before committing.
#
# Also reports which glyph name a codepoint corresponds to, using a cached
# copy of the Nerd Fonts glyphnames.json when one is available.
#
# Usage: scripts/check_group_icons.sh
#   Optional: NERD_GLYPHNAMES=/path/to/glyphnames.json for name lookups.
#            Curl it from https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json

set -euo pipefail

NIXVIM_DIR="${NIXVIM_DIR:-/home/cookiegigi/Projects/DEV/nixvim}"
SPEC_FILE="$NIXVIM_DIR/config/plugins/which-keys.nix"
CACHE=/tmp/nixvim-keymaps-glyphnames.json

if [ ! -f "$SPEC_FILE" ]; then
  echo "!! not found: $SPEC_FILE (set NIXVIM_DIR)" >&2
  exit 1
fi

if [ -n "${NERD_GLYPHNAMES:-}" ] && [ ! -f "$CACHE" ]; then
  cp "$NERD_GLYPHNAMES" "$CACHE"
fi

echo "==> Nerd Font families available:"
fc-list : family | tr ',' '\n' | grep -i 'nerd font' | sort -u | sed 's/^/    /' | head -5

# Resolve a python3. This host has none on the global PATH by design.
if command -v python3 >/dev/null 2>&1; then
  PY=python3
else
  PY="$(nix shell nixpkgs#python3 -c bash -c 'command -v python3')"
fi

# Extract "<leader>x" group -> U+XXXX codepoint pairs.
"$PY" - "$SPEC_FILE" > /tmp/nixvim-keymaps-icons.tsv <<'PY'
import re
import sys

src = open(sys.argv[1], encoding="utf-8").read()

# Each spec entry looks like: { "__unkeyed-1" = "<leader>d"; group = "Diagnostic"; icon = "<glyph>"; ... }
entry = re.compile(
    r'"__unkeyed-1"\s*=\s*"([^"]+)"\s*;\s*group\s*=\s*"([^"]+)"\s*;\s*icon\s*=\s*"([^"]*)"',
    re.S,
)

for key, group, icon in entry.findall(src):
    if not icon:
        print(f"{key}\t{group}\tEMPTY\t-")
        continue
    print(f"{key}\t{group}\t{ord(icon[0]):05X}\t{len(icon)}")
PY

# Optional codepoint -> glyph name lookup.
NAMES=/dev/null
if [ -f "$CACHE" ]; then
  NAMES="$CACHE"
  echo "==> using cached glyph names from $CACHE"
fi

"$PY" - "$NAMES" > /tmp/nixvim-keymaps-names.tsv <<'PY'
import json
import sys

try:
    data = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    raise SystemExit(0)

rev = {}
for name, v in data.items():
    if isinstance(v, dict) and "code" in v:
        rev.setdefault(int(v["code"], 16), []).append(name)

for cp, names in sorted(rev.items()):
    print(f"{cp:05X}\t{', '.join(sorted(names))}")
PY

echo
echo "==> group icons in $SPEC_FILE"
fail=0
while IFS=$'\t' read -r key group cp width; do
  if [ "$cp" = "EMPTY" ]; then
    printf '    %-10s %-12s %s\n' "$key" "$group" "EMPTY ICON"
    fail=1
    continue
  fi

  if [ "$width" != "1" ]; then
    printf '    %-10s %-12s U+%s  WARNING: %s codepoints in one icon field\n' \
      "$key" "$group" "$cp" "$width"
  fi

  # fontconfig charset matching: empty result means no installed font covers it.
  fonts="$(fc-list ":charset=$cp" family 2>/dev/null | head -1)"

  if [ -z "$fonts" ]; then
    printf '    %-10s %-12s U+%s  MISSING from every installed font\n' "$key" "$group" "$cp"
    fail=1
    continue
  fi

  name="$(awk -F'\t' -v c="$cp" '$1 == c { print $2; exit }' /tmp/nixvim-keymaps-names.tsv)"
  printf '    %-10s %-12s U+%s  OK  %s\n' "$key" "$group" "$cp" "${name:-<unnamed>}"
done < /tmp/nixvim-keymaps-icons.tsv

echo
if [ "$fail" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
  exit 1
fi