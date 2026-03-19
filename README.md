# bootstrap

Meta-repo for building and installing all Stardust XR components.

## Prerequisites

- [just](https://github.com/casey/just)
- Rust toolchain (cargo)
- Git

### Build dependencies

| Library | Fedora | Ubuntu | Arch |
|---------|--------|--------|------|
| alsa | `alsa-lib-devel` | `libasound2-dev` | `alsa-lib` |
| libevdev | `libevdev-devel` | `libevdev-dev` | `libevdev` |
| libffi | `libffi-devel` | `libffi-dev` | `libffi` |
| glib/gobject | `glib2-devel` | `libglib2.0-dev` | `glib2` |
| libgudev | `libgudev-devel` | `libgudev-1.0-dev` | `libgudev` |
| libinput | `libinput-devel` | `libinput-dev` | `libinput` |
| mtdev | `mtdev-devel` | `libmtdev-dev` | `mtdev` |
| libwacom | `libwacom-devel` | `libwacom-dev` | `libwacom` |
| wayland | `wayland-devel` | `libwayland-dev` | `wayland` |
| libxkbcommon | `libxkbcommon-devel` | `libxkbcommon-dev` | `libxkbcommon` |
| libxkbcommon-x11 | `libxkbcommon-x11-devel` | `libxkbcommon-x11-dev` | `libxkbcommon-x11` |
| libxcb | `libxcb-devel` | `libxcb1-dev libxcb-xkb-dev` | `libxcb` |
| udev | `systemd-devel` | `libudev-dev` | `systemd-libs` |
| libcap | `libcap-devel` | `libcap-dev` | `libcap` |

**Ubuntu:**
```sh
sudo apt install libasound2-dev libevdev-dev libffi-dev libglib2.0-dev libgudev-1.0-dev libinput-dev libmtdev-dev libwacom-dev libwayland-dev libxkbcommon-dev libxkbcommon-x11-dev libxcb1-dev libxcb-xkb-dev libudev-dev libcap-dev
```

**Fedora:**
```sh
sudo dnf install alsa-lib-devel libevdev-devel libffi-devel glib2-devel libgudev-devel libinput-devel mtdev-devel libwacom-devel wayland-devel libxkbcommon-devel libxkbcommon-x11-devel libxcb-devel systemd-devel libcap-devel
```

**Arch:**
```sh
sudo pacman -S alsa-lib libevdev libffi glib2 libgudev libinput mtdev libwacom wayland libxkbcommon libxkbcommon-x11 libxcb systemd-libs libcap
```

## Setup

```sh
git clone --recursive <repo-url>
```

## Commands

| Command | Description |
|---------|-------------|
| `just build` | Build all Stardust components in release mode |
| `just install` | Build and install all components to the system (default prefix: `/usr`) |
| `just uninstall` | Remove all installed components |
| `just update` | Pull the latest changes for all submodules |
| `just appdir-telescope` | Build a Telescope AppDir with all components bundled |
| `just prefix-install` | Install all components to a local `prefix/` directory |
| `just clean` | Remove all build artifacts |

### Install options

`install` and `uninstall` support `rootdir` and `prefix` overrides for staged or custom installs:

```sh
just rootdir="/tmp/staging" prefix="/usr/local" install
```

### Telescope AppDir

`just appdir-telescope` builds a self-contained `Telescope.AppDir/` that bundles the Stardust XR server, all clients, xwayland-satellite, and the Telescope launcher scripts. The resulting AppDir can be converted to an AppImage with [appimagetool](https://github.com/AppImage/appimagetool).
