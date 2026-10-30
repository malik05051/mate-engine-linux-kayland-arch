#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    printf 'Usage: %s <build_dir>\n' "$0" >&2
    exit 2
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
output_dir="$1"

if [[ ! -d "$output_dir" ]]; then
    printf 'Build directory does not exist: %s\n' "$output_dir" >&2
    exit 1
fi

"$script_dir/build-wayland-presenter.sh"
install -m 0755 "$script_dir/../Native/WaylandPresenter/build/matee-wayland-presenter" \
    "$output_dir/matee-wayland-presenter"
printf 'Packaged native Wayland presenter: %s\n' "$output_dir/matee-wayland-presenter"
