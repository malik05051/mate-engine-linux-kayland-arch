# Mate Engine: Native Wayland Fork

A desktop companion for **KDE Plasma 6 on native Wayland**, with transparent
avatars, custom VRM models, and window sitting.

This fork builds on [Mate-Engine-Linux-Port](https://github.com/Marksonthegamer/Mate-Engine-Linux-Port),
the unofficial Linux port of [Mate Engine](https://github.com/shinyflvre/Mate-Engine).
Its focus is native Wayland integration with KDE's KWin compositor.

![A Mate Engine avatar sitting on a Konsole window in KDE Plasma on native Wayland](Example.png)

*Window sitting on KDE Plasma 6 with KWin running Wayland.*

## Known issues: read before installing

- **Mods do not load correctly.**
- **Avatar controls depend on model naming and structure.** Automatic detection
  can be wrong; use Setup to rename or recategorize controls. Material and spring
  physics entries are read-only inventories, not editors.

## What works

- Transparent avatars with click-through outside their visible shape.
- Dragging, scrolling to resize, monitor-relative startup placement, and topmost
  control.
- Window and panel detection, sitting, and movement along window edges.
- Multi monitor setup with 3 different aspect ratios confirmed working in KDE6
- Custom VRM0 and VRM1 importing, automatic avatar controls, and saved presets.
- Presenter failure recovery: the Unity source window returns if the presenter
  stops.

Existing Mate Engine features include alarms, screensaver and Chibi modes,
mouse tracking, custom dances, event messages, localization, Discord RPC, and
optional AI chat. Dancing is experimental and uses PulseAudio or PipeWire's
PulseAudio compatibility service for audio application detection.

## Features added by this fork

- **Native KDE Wayland integration:** A transparent presenter provides
  click-through, pointer and keyboard input, dragging across monitors, scaling,
  and recovery if the presenter stops. KWin integration handles placement,
  topmost state, and desktop window geometry.
- **Window and panel sitting:** The avatar detects exposed top edges, sits on
  them, follows its supporting window, and detaches when the target is no longer
  eligible. Covered parts of a seated avatar are hidden and click-through.
- **Automatic avatar controls:** A custom scanner discovers controls from a
  loaded model and exposes them through the Clothes menu, including models
  without authored Mate Engine clothing entries.
- **Per-avatar setup and presets:** Rename, categorize, hide, and group controls,
  save presets, and restore imported defaults without modifying the model file.
- **Avatar library cleanup:** Loading the library removes entries for missing
  files or invalid paths while retaining model files and thumbnails.
- **Native Arch builds and portable export:** Helper scripts install the Arch
  packages and a checksum-verified, pinned Unity Editor; the exporter copies a
  player directory for other Arch/KDE machines.

### How automatic model detection works

After a model loads, the fork's
[`AvatarControlScanner`](Assets/MATE%20ENGINE%20-%20Scripts/AvatarControls/AvatarControls.cs)
inspects its mesh renderers, blendshapes, VRM0/VRM1 expressions, and existing
`MEClothes` entries. It reads available VRM title, author, and version metadata.
Authored clothing entries retain their own controls; other meshes and morphs
receive controls discovered from the model's contents.

Name-based rules organize clothing, accessories, body morphs, and facial controls.
Matching normalized morph names on body and clothing meshes are linked so one
slider can adjust both. Recognized clothing correction morphs can follow an
outfit's visibility. This detection depends on model structure and naming;
unrecognized meshes appear under Uncategorized, and raw controls are available
in Advanced. Setup lets you correct the organization manually.

Saved profiles are matched first by the model file's SHA-256 hash, then by a
signature derived from its metadata and discovered structure. This allows a
renamed or moved file to retain its settings. Ambiguous matches use defaults
until a profile is selected. Profiles live in Unity's per-user `AvatarProfiles`
directory, outside the model file.

## Supported desktop

| Environment | Status |
| --- | --- |
| KDE Plasma 6 / KWin, native Wayland | Supported target |
| Other Wayland compositors | Unsupported; desktop integration currently depends on KWin backend, don't expect it to even render, |
| X11 / XWayland | Outside this fork's scope; use the source project for x11, this fork is for specifically wayland support |

The development baseline uses Arch Linux and Unity `6000.2.6f2`.

## Build and run

You need Arch Linux (or a derivative) running KDE Plasma 6 in a Wayland session.
Everything builds against the system's own packages: the presenter uses the
host Qt 6 and `layer-shell-qt`, and Unity uses the host GPU drivers directly.
`build.sh` runs Unity in batch mode, so it needs no Unity account, Unity Hub, or
license activation.

From the repository root:

```sh
./scripts/install-arch-deps.sh
./scripts/install-unity-editor.sh
./build.sh ./Build
cd Build
env -u DISPLAY ./launch.sh
```

`install-arch-deps.sh` installs the build and runtime packages with pacman.
`install-unity-editor.sh` downloads the pinned Unity `6000.2.6f2` Editor (about
4 GiB, checksum-verified) to `~/.local/share/mate-engine/unity`, where
`build.sh` finds it. To use an Editor installed elsewhere, such as through Unity
Hub, set `UNITY_EDITOR_PATH`. The first import and build can take several
minutes. Keep the ignored `Library/` directory to reuse Unity's asset and
shader caches.

The build compiles the `StandaloneFileBrowser` native plugin from source, builds
the Unity player, and builds and packages the native Wayland presenter. Use
`launch.sh` to start the player: it selects native Wayland and starts the
presenter. Confirm `Selected window backend: wayland` in the Unity player log.

`build.sh` needs a graphical session and GPU access, because Unity must have a
graphics device while building; without one, the player shows a broken splash
screen. Install your GPU's drivers as usual (`mesa` with `vulkan-radeon` or
`vulkan-intel`, or `nvidia-utils`); `build.sh` warns when Unity found no GPU. On
a machine without a display, `MATEENGINE_BUILD_HEADLESS=1 ./build.sh ./Build`
still builds for quick iteration, but don't publish the result.

### Building from the Editor

You can also build from the Unity Editor GUI. Unlike `build.sh`, the Editor
requires signing in to your own Unity account and activating a license (Unity
Personal is enough) through Unity Hub, available from the AUR as
[`unityhub`](https://aur.archlinux.org/packages/unityhub):

```sh
yay -S unityhub
```

Then open the project:

```sh
./scripts/build-file-browser.sh
./scripts/prepare-llamalib.sh
~/.local/share/mate-engine/unity/6000.2.6f2/Editor/Unity -projectPath "$PWD"
```

Choose **MateEngine > Build Linux Player...**, select the `Build` folder, and
then package the native Wayland presenter:

```sh
./scripts/package-build.sh ./Build
```

Source-project packages do not contain this fork's native Wayland integration.
See [usage.md](usage.md) for build options, Editor launch, runtime requirements,
and troubleshooting.

### Portable export

To copy a player to another machine, export it into a new directory:

```sh
MATEENGINE_PORTABLE_PLUGIN=1 ./build.sh ./Build
./scripts/export-portable.sh ./Build ./MateEngine-portable
```

The destination must not already exist. The presenter links against the host
Qt 6, so the target machine needs `qt6-base`, `qt6-wayland`, `layer-shell-qt`,
GTK 3, graphics drivers, and KDE Plasma 6 on Wayland. Test it on the target
machine before sharing it. See [portable export instructions](usage.md#build-a-player).

## Using your companion

| Action | Control |
| --- | --- |
| Open the radial menu | Right-click the avatar |
| Move the avatar | Left-click and drag |
| Change avatar size | Scroll over the avatar |
| Sit on a window or panel | Enable window sitting, hold a drag for at least one second, and cross an exposed top edge with the avatar's hips |
| Adjust an imported avatar | Open Clothes to access Avatar Controls |
| Lifecycle and window actions | Use the tray menu |

Imported VRM avatars expose discovered clothing, body morphs, expressions, and
face morphs. Linked body and clothing morphs adjust together. Advanced shows raw
controls and material/physics inventories; Setup lets you organize controls, and
presets save combinations. Keyboard input is available while Avatar Controls is
open, with the `ABC` on-screen keyboard as a fallback.

Profiles are saved under `AvatarProfiles` in Unity's per-user data directory;
model files are not modified. Reset restores imported defaults. Existing `.me`
clothing keeps its authored behavior.

Opening or reloading the avatar library removes entries whose source files are
missing or whose paths are invalid. It does not delete model files or thumbnails.
Models on disconnected storage must be reimported after reconnecting it.

Optional AI chat requires your own `llama-3.2-3b-instruct-q4_k_m.gguf` beside the
player executable. Model weights and local test avatars are not distributed with
this fork.

## Development and bug reports

Unity renders the avatar; a separate native Wayland presenter displays its RGBA
frames and forwards input. KWin integration supplies desktop geometry and window
operations. Technical details live in the [presenter documentation](Native/WaylandPresenter/README.md)
and [sitting validation guide](Native/WaylandPresenter/VALIDATION.md).

For a bug report, include reproduction steps, the revision and launch command,
Plasma/KWin version, graphics API and renderer, monitor layout and scales, and
relevant Unity/presenter log lines. Record `XDG_SESSION_TYPE`, whether
`WAYLAND_DISPLAY` and `DISPLAY` are set, and the observed Unity backend. Review
logs for personal information before sharing them.

## License

This fork retains the upstream **MateEngine Pro License (v2.0)**. See
[LICENSE](LICENSE) for its terms, including the separate asset terms. Bundled
third-party components retain their own licenses and notices in
[Third Party Licenses](Third%20Party%20Licenses/).
