#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="${1:-/Users/edgariraheta/Documents/Codex/2026-06-18/ca/outputs/codex-meter-demo.mp4}"
FFMPEG="${FFMPEG:-/opt/homebrew/bin/ffmpeg}"

mkdir -p "$(dirname "$OUTPUT_PATH")"

"$FFMPEG" -y \
  -loop 1 -t 5 -i "$ROOT_DIR/docs/assets/codex-meter-widget-circular.png" \
  -loop 1 -t 4.5 -i "$ROOT_DIR/docs/assets/codex-meter-settings.png" \
  -loop 1 -t 4.5 -i "$ROOT_DIR/docs/assets/codex-meter-widget-bars.png" \
  -loop 1 -t 5 -i "$ROOT_DIR/docs/assets/codex-meter-widget-battery.png" \
  -filter_complex "
    [0:v]fps=30,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,gblur=sigma=24,eq=brightness=0.035:saturation=1.08,format=rgba[bg0];
    [0:v]fps=30,scale=700:940:force_original_aspect_ratio=decrease,format=rgba[fg0];
    [bg0][fg0]overlay=(W-w)/2:(H-h)/2,setsar=1[v0];
    [1:v]fps=30,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,gblur=sigma=24,eq=brightness=0.035:saturation=1.08,format=rgba[bg1];
    [1:v]fps=30,scale=1180:760:force_original_aspect_ratio=decrease,format=rgba[fg1];
    [bg1][fg1]overlay=(W-w)/2:(H-h)/2,setsar=1[v1];
    [2:v]fps=30,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,gblur=sigma=24,eq=brightness=0.035:saturation=1.08,format=rgba[bg2];
    [2:v]fps=30,scale=700:940:force_original_aspect_ratio=decrease,format=rgba[fg2];
    [bg2][fg2]overlay=(W-w)/2:(H-h)/2,setsar=1[v2];
    [3:v]fps=30,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,gblur=sigma=24,eq=brightness=0.035:saturation=1.08,format=rgba[bg3];
    [3:v]fps=30,scale=700:940:force_original_aspect_ratio=decrease,format=rgba[fg3];
    [bg3][fg3]overlay=(W-w)/2:(H-h)/2,setsar=1[v3];
    [v0][v1]xfade=transition=fade:duration=0.75:offset=4.25[v01];
    [v01][v2]xfade=transition=fade:duration=0.75:offset=8.0[v012];
    [v012][v3]xfade=transition=fade:duration=0.75:offset=11.75[v]
  " \
  -map "[v]" \
  -c:v libx264 \
  -preset medium \
  -crf 20 \
  -pix_fmt yuv420p \
  -movflags +faststart \
  "$OUTPUT_PATH"

echo "$OUTPUT_PATH"
