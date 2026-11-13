#!/usr/bin/env bash
# Extract a graphics archive and merge it into a Football Manager graphics folder.
#
# Usage: install_pack.sh <archive> <target-dir>
#   <archive>     .zip / .7z / .rar graphics pack
#   <target-dir>  e.g. <graphics-root>/logos   (created if missing)
#
# Refuses partial downloads and archives without a config.xml, because an FM
# graphics pack without config.xml maps no images to anything.
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "usage: install_pack.sh <archive> <target-dir>" >&2
  exit 2
fi

archive=$1
target=$2

[ -f "$archive" ] || { echo "ERROR: archive not found: $archive" >&2; exit 1; }
case "$archive" in
  *.part) echo "ERROR: partial download: $archive" >&2; exit 1 ;;
esac

stage=$(mktemp -d "${TMPDIR:-/tmp}/fm-graphics-install.XXXXXX")
trap 'rm -rf "$stage"' EXIT

echo "== extracting $(basename "$archive")"
case "$archive" in
  *.rar) unrar x -o+ -idq "$archive" "$stage"/ > /dev/null ;;
  *)     7z x -y -o"$stage" "$archive" > /dev/null ;;
esac
files=$(find "$stage" -type f | wc -l)
size=$(du -sh "$stage" | cut -f1)
echo "== extracted $files files, $size"

mapfile -t cfgs < <(find "$stage" -iname config.xml)
if [ ${#cfgs[@]} -eq 0 ]; then
  echo "ERROR: no config.xml in archive; not installing" >&2
  exit 1
fi
echo "== found ${#cfgs[@]} config.xml"

mkdir -p "$target"
cp -a "$stage"/. "$target"/
echo "== installed into $target"
