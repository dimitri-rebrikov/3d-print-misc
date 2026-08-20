#!/usr/bin/env bash
# render_views.sh — Rendert ISO/TOP/FRONT/RIGHT-Ansichten einer OpenSCAD-Datei als PNG.
# Teil des Design-Review-Loops: SCAD -> Render -> Vision-Analyse -> Iteration.
#
# Nutzung:
#   render_views.sh <model.scad> [--size 800] [--outdir views]
#
# Ausgabe: <outdir>/<basename>_iso.png, _top.png, _front.png, _right.png
# (outdir relativ zum SCAD-Verzeichnis, Default: views/)
#
# Besonderheiten (headless Linux):
#  - PNG-Rendering braucht einen X-Server (OpenGL-Kontext): startet Xvfb :99, falls keiner läuft
#  - Workaround fuer Mesa/libdrm-Konflikt: wenn /opt/amdgpu (ROCm) die System-libdrm_amdgpu
#    ueberschattet, wird die System-Bibliothek per LD_PRELOAD erzwungen
#  - Kamerawinkel sind relativ zur Draufsicht: rx=0 -> Blick von oben, rx=90 -> seitlich

set -euo pipefail

SCAD="${1:?Usage: render_views.sh <model.scad> [--size N] [--outdir DIR]}"
shift || true

SIZE=800
OUTDIR="views"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --size) SIZE="${2:?--size braucht Wert}"; shift 2 ;;
        --outdir) OUTDIR="${2:?--outdir braucht Wert}"; shift 2 ;;
        *) echo "Unbekanntes Argument: $1" >&2; exit 1 ;;
    esac
done

[[ -f "$SCAD" ]] || { echo "SCAD-Datei nicht gefunden: $SCAD" >&2; exit 1; }

SCAD_DIR="$(cd "$(dirname "$SCAD")" && pwd)"
BASE="$(basename "$SCAD" .scad)"
OUT_DIR="$SCAD_DIR/$OUTDIR"
mkdir -p "$OUT_DIR"

# --- Xvfb sicherstellen -----------------------------------------------------
DISPLAY_NUM="${DISPLAY_NUM:-:99}"
if ! pgrep -f "Xvfb $DISPLAY_NUM" >/dev/null 2>&1; then
    # Stale Sockets/Locks raeumen (kein laufender Prozess dazu)
    rm -f "/tmp/.X${DISPLAY_NUM#:}-lock" "/tmp/.X11-unix/X${DISPLAY_NUM#:}"
    LD_PRELOAD="${PRELOAD:-}" Xvfb "$DISPLAY_NUM" -screen 0 1280x1024x24 >/dev/null 2>&1 &
    sleep 2
fi
export DISPLAY="$DISPLAY_NUM"

# --- Mesa/libdrm-Konflikt (ROCm /opt/amdgpu) umgehen ------------------------
PRELOAD="${PRELOAD:-}"
if [[ -z "$PRELOAD" ]]; then
    RESOLVED="$(ldconfig -p | awk '/libdrm_amdgpu\.so\.1/{print $NF; exit}')"
    if [[ "$RESOLVED" == /opt/amdgpu/* ]]; then
        SYSTEM_LIB="$(ldconfig -p | awk '/libdrm_amdgpu\.so\.1/{print $NF}' | grep -v '^/opt/' | head -1)"
        [[ -n "$SYSTEM_LIB" ]] && PRELOAD="$SYSTEM_LIB"
    fi
fi
export LD_PRELOAD="$PRELOAD"
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"

# --- Views rendern -----------------------------------------------------------
# Kamerawinkel relativ zur Draufsicht (empirisch, OpenSCAD 2021.01):
#   iso:   rx=55, rz=45, perspektivisch
#   top:   rx=0             -> Silhouette X x Y
#   front: rx=90            -> Silhouette X x Z
#   right: rx=90, rz=90     -> Silhouette Y x Z
declare -A VIEWS=(
    [iso]="55,0,45,perspective"
    [top]="0,0,0,ortho"
    [front]="90,0,0,ortho"
    [right]="90,0,90,ortho"
)

FAILED=0
for view in iso top front right; do
    IFS=',' read -r RX RY RZ PROJ <<< "${VIEWS[$view]}"
    OUT="$OUT_DIR/${BASE}_${view}.png"
    CAMERA_ARGS=(--render --autocenter --viewall "--camera=0,0,0,$RX,$RY,$RZ,500" "--imgsize=$SIZE,$SIZE")
    [[ "$PROJ" == ortho ]] && CAMERA_ARGS+=(--projection=ortho)
    if openscad -o "$OUT" "${CAMERA_ARGS[@]}" "$SCAD" >/dev/null 2>&1 && [[ -s "$OUT" ]]; then
        echo "OK   $view -> $OUT"
    else
        echo "FEHLER $view -> $OUT (SCAD-Fehler? Log: openscad -o $OUT ... $SCAD)" >&2
        FAILED=1
    fi
done

exit $FAILED
