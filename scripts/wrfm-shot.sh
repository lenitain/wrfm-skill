#!/usr/bin/env bash
# wrfm-shot.sh — turn a .wrfm model into a PNG image a multimodal model can SEE.
# Usage:
#   wrfm-shot.sh <model.wrfm> <out.png>                 # all six standard views, 2x3 montage
#   wrfm-shot.sh <model.wrfm> <out.png> --views front   # extra args are passed to `wrfm render`
#                                                       #   (single view / group / region / camera)
# Depends on: `wrfm` CLI on PATH, ImageMagick (`magick`).
set -euo pipefail

MODEL="${1:?usage: wrfm-shot.sh <model.wrfm> <out.png> [render args...]}"
OUT="${2:?usage: wrfm-shot.sh <model.wrfm> <out.png> [render args...]}"
shift 2

BG='#0d1117'   # dark background, any terminal
FG='#9cdcfe'   # light blue foreground — visible on dark
PT=16          # pointsize: 120 braille cols * ~9.8px/char -> ~1180px wide per view

command -v wrfm  >/dev/null || { echo "wrfm-shot: wrfm CLI not found on PATH" >&2; exit 2; }
command -v magick >/dev/null || { echo "wrfm-shot: magick not found on PATH" >&2; exit 2; }

FONT=''
FONTLIST="$(magick -list font)"
for f in DejaVu-Sans-Mono Monospace; do
  if grep -qi "$f" <<< "$FONTLIST"; then FONT="$f"; break; fi
done
[ -n "$FONT" ] || FONT='Monospace'

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

to_png() { # $1 = output path; reads render text from stdin
  magick -background "$BG" -fill "$FG" -font "$FONT" -pointsize "$PT" label:@- "$1"
}

if [ "$#" -gt 0 ]; then
  # explicit render args -> ONE frame (single view / group / region / camera)
  wrfm render "$MODEL" --format braille --width 120 --height 60 "$@" | to_png "$OUT"
else
  i=0
  for v in front back left right top bottom; do
    wrfm render "$MODEL" --format braille --width 120 --height 60 --views "$v" | to_png "$tmp/$i.png"
    i=$((i + 1))
  done
  magick montage "$tmp"/*.png -tile 2x -geometry +6+6 -background "$BG" "$OUT"
fi

echo "wrfm-shot: wrote $OUT ($(wc -c < "$OUT") bytes)"
