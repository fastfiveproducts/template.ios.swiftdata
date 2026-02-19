#!/usr/bin/env zsh
set -euo pipefail

# ——— TO USE ———
# update configuration below
# make this executable with 'chmod +x template_diff.zsh'
# run with './template_diff.zsh'
# ————————————————

# ——— CONFIGURUTION ———
TEMPLATE_DIR="../../template.ios/template"
PROJECT_DIR="."
OUTPUT_FILE="./template_diff.txt"
# ————————————————

# Start capturing all stdout into $OUTPUT_FILE
exec >| "$OUTPUT_FILE"

# Print key info to your console on stderr:
echo "🔍 Comparing template vs project…" >&2

# Find all template file; strip off the leading path
# (grep -rl finds files
# ${(f)“…“} splits on newlines into tpl_files array)
typeset -a tpl_files
tpl_files=(${(f)"$(grep -rl '^// *Template v' -- "$TEMPLATE_DIR")"})

if (( ${#tpl_files} == 0 )); then
  echo "⚠️  No template files found under $TEMPLATE_DIR"
  exit 1
fi

echo "🔍 Found ${#tpl_files} template files. Comparing…"
echo

for tpl in $tpl_files; do
  rel=${tpl#"$TEMPLATE_DIR/"}
  prj="$PROJECT_DIR/$rel"

  if [[ -f "$prj" ]]; then
    echo "── $rel ──"
    diff -u -- "$tpl" "$prj" || true
    echo
  else
    echo "⚠️  Skipping (not in project): $rel"
    echo
  fi
done

echo "✅ Done. Full diff saved to $OUTPUT_FILE"
echo "✅ Done. Full diff saved to $OUTPUT_FILE" >&2

