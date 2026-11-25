#!/usr/bin/env bash
# Compila una clase a PDF (y su versión handout, sin pasos).
#   ./compilar.sh clase1-scc            -> clase1-scc/main.pdf + clase1-scc/main-handout.pdf
#   ./compilar.sh clase1-scc --watch    -> recompila al guardar (solo slides)
set -euo pipefail
cd "$(dirname "$0")"
dir="${1:?uso: ./compilar.sh <carpeta-clase> [--watch]}"
dir="${dir%/}"
if [[ "${2:-}" == "--watch" ]]; then
  exec typst watch --root . "$dir/main.typ" "$dir/main.pdf"
fi
typst compile --root . "$dir/main.typ" "$dir/main.pdf"
typst compile --root . --input handout=true "$dir/main.typ" "$dir/main-handout.pdf"
echo "OK: $dir/main.pdf, $dir/main-handout.pdf"
