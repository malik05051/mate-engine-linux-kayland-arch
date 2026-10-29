#!/usr/bin/env bash
# Install the Arch Linux packages needed to build and run Mate Engine.
set -euo pipefail

if ! command -v pacman >/dev/null 2>&1; then
    printf 'pacman was not found; this script targets Arch Linux and its derivatives.\n' >&2
    exit 1
fi

packages=(
    # Build tools
    base-devel cmake pkgconf git patchelf curl tar xz
    # Native Wayland presenter
    qt6-base qt6-wayland layer-shell-qt wayland wayland-protocols
    # StandaloneFileBrowser plugin, tray menu and audio detection
    gtk3 glib2 libayatana-appindicator libpulse
    # Unity Editor and player runtime libraries
    nss nspr libsecret libnotify libxss libxtst libxkbcommon libxcomposite
    libxcursor libxdamage libxrandr libxi alsa-lib at-spi2-core cups dbus
    icu krb5 libxml2-legacy libglvnd mesa vulkan-icd-loader libva xdg-utils
    ttf-dejavu ttf-liberation
    # Tests and diagnostics
    nodejs python python-dbus python-gobject mesa-utils vulkan-tools
    xorg-xdpyinfo
)

sudo pacman -S --needed "$@" "${packages[@]}"

cat <<'NOTE'

Installed the Arch packages for Mate Engine.
Next, install the pinned Unity Editor:

    ./scripts/install-unity-editor.sh

GPU drivers come from the host: AMD and Intel use mesa (installed above) with
vulkan-radeon or vulkan-intel; NVIDIA uses nvidia-utils.
NOTE
