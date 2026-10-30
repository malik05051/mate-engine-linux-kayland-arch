#!/usr/bin/env bash
# Download and verify the pinned Unity Editor, which bundles Linux Mono build
# support. No Unity account or Unity Hub is needed for batch-mode builds.
set -euo pipefail

version=6000.2.6f2
url="https://download.unity3d.com/download_unity/4a4dcaec6541/LinuxEditorInstaller/Unity-$version.tar.xz"
sha256=2eedf4b6bbaf390799e5900b277245d06423181a3a66f7d58821de84ce74f036

install_root="${MATEENGINE_UNITY_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/mate-engine/unity}"
destination="$install_root/$version"
editor="$destination/Editor/Unity"

if [[ -x "$editor" ]]; then
    printf 'Unity %s is already installed: %s\n' "$version" "$editor"
    exit 0
fi

mkdir -p -- "$install_root"
stage="$(mktemp -d "$install_root/.install-$version.XXXXXX")"
trap 'rm -rf -- "$stage"' EXIT

archive="$stage/Unity-$version.tar.xz"
printf 'Downloading Unity %s (about 4 GiB)...\n' "$version"
curl --fail --location --output "$archive" "$url"
printf '%s  %s\n' "$sha256" "$archive" | sha256sum --check --quiet

mkdir -p -- "$stage/root"
tar -xJf "$archive" -C "$stage/root"
rm -f -- "$archive"
test -x "$stage/root/Editor/Unity"
test -d "$stage/root/Editor/Data/PlaybackEngines/LinuxStandaloneSupport"

mv -- "$stage/root" "$destination"
printf 'Installed Unity %s: %s\n' "$version" "$editor"
printf 'build.sh finds it automatically; to use it elsewhere, set UNITY_EDITOR_PATH=%q\n' "$editor"
