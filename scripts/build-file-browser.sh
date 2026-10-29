#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/.." && pwd)"
source_dir="$project_dir/Plugins/StandaloneFileBrowser"
build_dir="$source_dir/build"
destination="$project_dir/Assets/MATE ENGINE - Packages/StandaloneFileBrowser/Plugins/Linux/x86_64/libStandaloneFileBrowser.so"

if [[ "${MATEENGINE_PORTABLE_PLUGIN:-0}" == 1 ]]; then
    # Use the standard x86-64 loader and the destination host's GTK, without
    # development RPATHs.
    command -v patchelf >/dev/null
    make -C "$source_dir" build/dialog
    patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 --remove-rpath "$build_dir/dialog"
    touch "$build_dir/dialog"
fi
make -C "$source_dir" build/libStandaloneFileBrowser.so
if [[ "${MATEENGINE_PORTABLE_PLUGIN:-0}" == 1 ]]; then
    patchelf --remove-rpath "$build_dir/libStandaloneFileBrowser.so"
fi
install -Dm755 "$build_dir/libStandaloneFileBrowser.so" "$destination"
printf 'Installed audited StandaloneFileBrowser plugin to %s\n' "$destination"
