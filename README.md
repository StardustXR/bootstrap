# bootstrap

Meta-repo for building and installing all Stardust XR components.

## Prerequisites

- [just](https://github.com/casey/just)
- Rust toolchain (cargo)
- Git

### Build dependencies

| Library | Used by | Fedora | Ubuntu | Arch |
|---------|---------|--------|--------|------|
| wayland | stardust-xr-server | `wayland-devel` | `libwayland-dev` | `wayland` |
| alsa | stardust-xr-server | `alsa-lib-devel` | `libasound2-dev` | `alsa-lib` |
| libffi | stardust-xr-server | `libffi-devel` | `libffi-dev` | `libffi` |
| libinput | eclipse | `libinput-devel` | `libinput-dev` | `libinput` |
| libxkbcommon | azimuth, eclipse, manifold, simular | `libxkbcommon-devel` | `libxkbcommon-dev` | `libxkbcommon` |

Other libraries (libevdev, mtdev, libwacom, libgudev, glib, udev, libcap, libxcb) are pulled in transitively by the above.

**Fedora:**
```sh
sudo dnf install wayland-devel alsa-lib-devel libffi-devel libinput-devel libxkbcommon-devel
```

**Ubuntu:**
```sh
sudo apt install libwayland-dev libasound2-dev libffi-dev libinput-dev libxkbcommon-dev
```

**Arch:**
```sh
sudo pacman -S wayland alsa-lib libffi libinput libxkbcommon
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
