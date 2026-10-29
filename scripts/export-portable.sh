#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 2 ]]; then
    printf 'Usage: %s <player-build-directory> <new-output-directory>\n' "$0" >&2
    exit 2
fi

source_dir="$(realpath -- "$1")"
output_dir="$(realpath -m -- "$2")"

if [[ ! -x "$source_dir/MateEngineX.x86_64" || ! -f "$source_dir/UnityPlayer.so" ||
      ! -d "$source_dir/MateEngineX_Data" || ! -f "$source_dir/launch.sh" ||
      ! -x "$source_dir/matee-wayland-presenter" ]]; then
    printf 'Incomplete Unity player build: %s\n' "$source_dir" >&2
    exit 1
fi
if [[ -e "$output_dir" || -L "$output_dir" ]]; then
    printf 'Output already exists; refusing to overwrite: %s\n' "$output_dir" >&2
    exit 1
fi

output_parent="$(dirname -- "$output_dir")"
mkdir -p -- "$output_parent"
stage="$(mktemp -d "$output_parent/.matee-portable.XXXXXXXX")"
trap 'printf "Export did not complete; staging files remain at %s\n" "$stage" >&2' ERR

cp -a -- "$source_dir/MateEngineX.x86_64" "$source_dir/UnityPlayer.so" \
    "$source_dir/MateEngineX_Data" "$source_dir/launch.sh" \
    "$source_dir/matee-wayland-presenter" "$stage/"
for library in libdecor-0.so.0 libdecor-cairo.so; do
    if [[ -f "$source_dir/$library" ]]; then
        cp -a -- "$source_dir/$library" "$stage/"
    fi
done

if find "$stage" -type l -print -quit | grep -q .; then
    printf 'Export contains a symlink; inspect staging directory: %s\n' "$stage" >&2
    exit 1
fi

mv -- "$stage" "$output_dir"
trap - ERR
printf 'Portable player directory: %s\n' "$output_dir"
printf 'The presenter links against the host Qt 6; on Arch the destination needs:\n'
printf '    sudo pacman -S --needed qt6-base qt6-wayland layer-shell-qt gtk3 libayatana-appindicator libpulse\n'
printf 'On a KDE Plasma 6 Wayland system: cd %q && env -u DISPLAY ./launch.sh\n' "$output_dir"
