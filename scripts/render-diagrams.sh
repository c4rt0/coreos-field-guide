#!/usr/bin/env bash
# Render diagram sources (.drawio, .mmd) to PNG files beside them, locally.
#
# Diagram sources never leave this machine: rendering uses the draw.io desktop
# CLI only. Do not add online renderers (kroki.io, mermaid.ink, etc.) here.
#
# Usage:
#   scripts/render-diagrams.sh            render sources whose PNG is missing or older
#   scripts/render-diagrams.sh --all      re-render every source
#   scripts/render-diagrams.sh FILE...    render the given .drawio/.mmd files
#   scripts/render-diagrams.sh --check    verify every source has a PNG and every
#                                         PNG has a source (no rendering; used in CI)

set -euo pipefail

cd "$(dirname "$0")/.."

list_sources() {
  find . -path ./.git -prune -o \( -name '*.drawio' -o -name '*.mmd' \) -type f -print | sort
}

png_for() { printf '%s.png\n' "${1%.*}"; }

check_pairs() {
  local status=0 src png base
  while IFS= read -r src; do
    png=$(png_for "$src")
    [ -f "$png" ] || { echo "missing PNG for source: $src"; status=1; }
  done < <(list_sources)
  while IFS= read -r png; do
    base=${png%.png}
    [ -f "$base.drawio" ] || [ -f "$base.mmd" ] || [[ "$png" == ./.github/* ]] \
      || { echo "PNG without a .drawio/.mmd source: $png"; status=1; }
  done < <(find . -path ./.git -prune -o -name '*.png' -type f -print | sort)
  # draw.io renders malformed XML without an error, silently dropping shapes.
  if command -v python3 >/dev/null; then
    list_sources | grep '\.drawio$' | python3 -c '
import sys, xml.dom.minidom
bad = 0
for path in sys.stdin.read().split("\n"):
    if not path: continue
    try: xml.dom.minidom.parse(path)
    except Exception as e: print(f"invalid XML in {path}: {e}"); bad = 1
sys.exit(bad)' || status=1
  else
    echo "python3 not found; skipping .drawio XML validation" >&2
  fi
  [ "$status" -eq 0 ] && echo "diagram check: every source and PNG is paired, .drawio sources are valid XML"
  return "$status"
}

# draw.io is an Electron app and needs a display, even for CLI export.
drawio_cmd() {
  command -v drawio >/dev/null || {
    echo "drawio CLI not found. Install draw.io desktop: https://github.com/jgraph/drawio-desktop/releases" >&2
    echo "Do not fall back to an online renderer." >&2
    exit 1
  }
  local runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
  if [ -n "${DISPLAY:-}" ]; then
    DRAWIO=(drawio)
  elif [ -n "${WAYLAND_DISPLAY:-}" ] || [ -S "$runtime/wayland-0" ]; then
    export XDG_RUNTIME_DIR=$runtime WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}
    DRAWIO=(drawio --ozone-platform=wayland)
  elif command -v xvfb-run >/dev/null; then
    DRAWIO=(xvfb-run -a drawio)
  else
    echo "No display found. Run from a desktop session or install xvfb-run." >&2
    exit 1
  fi
}

render() {
  local src=$1 png
  png=$(png_for "$src")
  DRAWIO_DISABLE_UPDATE=true "${DRAWIO[@]}" --export --format png \
    --border 20 ${DRAWIO_EXPORT_ARGS:-} -o "$png" "$src" 2>/dev/null \
    | grep -F -- '->' || { echo "failed: $src" >&2; return 1; }
}

case "${1:-}" in
  --check) check_pairs; exit ;;
  -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit ;;
esac

drawio_cmd
failed=0
if [ "$#" -gt 0 ] && [ "$1" != "--all" ]; then
  for src in "$@"; do
    case "$src" in *.drawio|*.mmd) ;; *) echo "not a diagram source: $src" >&2; failed=1; continue ;; esac
    render "$src" || failed=1
  done
else
  while IFS= read -r src; do
    png=$(png_for "$src")
    if [ "${1:-}" = "--all" ] || [ ! -f "$png" ] || [ "$src" -nt "$png" ]; then
      render "$src" || failed=1
    fi
  done < <(list_sources)
fi
exit "$failed"
