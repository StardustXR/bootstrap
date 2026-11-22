just := just_executable()
rootdir := ''
server_cargo_flags := ''
server_env_vars := ''
prefix := '/usr'
telescope_appdir := justfile_directory() / "Telescope.AppDir"
prefix_dir := justfile_directory() / 'prefix' / 'usr'
# signed by the type2-runtime key 570C77ACEA40C0F1B758902CBF96CCA56490F695
appimage_runtime_version := '20251108'
appimage_runtime_sha256 := if arch() == "x86_64" { '2fca8b443c92510f1483a883f60061ad09b46b978b2631c807cd873a47ec260d' } else if arch() == "aarch64" { '00cbdfcf917cc6c0ff6d3347d59e0ca1f7f45a6df1a428a0d6d8a78664d87444' } else { '' }
appimagetool_version := '1.9.1'
appimagetool_sha256 := if arch() == "x86_64" { 'ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0' } else if arch() == "aarch64" { 'f0837e7448a0c1e4e650a93bb3e85802546e60654ef287576f46c71c126a9158' } else { '' }

build:
    {{ just }} org.stardustxr.Armillary/build-release
    {{ just }} org.stardustxr.Atmosphere/build-release
    {{ just }} org.stardustxr.BlackHole/build-release
    {{ just }} org.stardustxr.Comet/build-release
    {{ just }} org.stardustxr.Flatland/build-release
    {{ just }} org.stardustxr.Gravity/build-release
    {{ just }} org.stardustxr.NonSpatialInput/build-release
    {{ just }} org.stardustxr.Protostar/build-release
    {{ just }} org.stardustxr.SolarSailer/build-release
    {{ just }} org.stardustxr.Server/build-release {{ server_cargo_flags }}
    {{ just }} org.stardustxr.WaylandService/build-release
    {{ just }} org.stardustxr.PalmLauncher/build-release

install:
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Atmosphere/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Armillary/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.BlackHole/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Comet/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Flatland/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Gravity/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.NonSpatialInput/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Protostar/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.SolarSailer/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Server/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.WaylandService/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.PalmLauncher/install

uninstall:
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Armillary/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Atmosphere/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.BlackHole/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Comet/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Flatland/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Gravity/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.NonSpatialInput/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Protostar/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.SolarSailer/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Server/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.WaylandService/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.PalmLauncher/uninstall

build_read_only_deps:
    {{ just }} _build_vendored_readonly org.stardustxr.Armillary
    {{ just }} _build_vendored_readonly org.stardustxr.Atmosphere
    {{ just }} _build_vendored_readonly org.stardustxr.BlackHole
    {{ just }} _build_vendored_readonly org.stardustxr.Comet
    {{ just }} _build_vendored_readonly org.stardustxr.Flatland
    {{ just }} _build_vendored_readonly org.stardustxr.Gravity
    {{ just }} _build_vendored_readonly org.stardustxr.NonSpatialInput
    {{ just }} _build_vendored_readonly org.stardustxr.Protostar --no-default-features
    {{ just }} _build_vendored_readonly org.stardustxr.SolarSailer
    {{ server_env_vars }} {{ just }} _build_vendored_readonly org.stardustxr.Server {{ server_cargo_flags }}
    {{ just }} _build_vendored_readonly org.stardustxr.WaylandService
    {{ just }} _build_vendored_readonly org.stardustxr.PalmLauncher --no-default-features

_build_vendored_readonly target *args:
    #!/usr/bin/env sh
    cd {{ target }}
    {{ if path_exists(target) == "true" { 'chmod -R +w vendor' } else { '' } }}    
    {{ just }} vendor
    {{ if path_exists(target) == "true" { 'chmod -R +w vendor' } else { '' } }}    
    {{ if path_exists(target) == "true" { 'rm -rf vendor' } else { '' } }}    
    tar pxf vendor.tar
    chmod -R -w vendor
    {{ just }} build-release '--frozen --offline' {{ args }}
    chmod -R +w vendor

appdir-telescope: build_read_only_deps
    mkdir -p "{{ telescope_appdir }}"

    # Install all the stardust components
    {{ just }} rootdir="{{ telescope_appdir }}" prefix="/usr" install

    # xwayland-satellite
    if ! test -f "{{ telescope_appdir }}/usr/bin/xwayland-satellite"; then \
        cargo install --locked --git "https://github.com/Supreeeme/xwayland-satellite" --root "{{ telescope_appdir }}/usr" --force && \
        rm -f "{{ telescope_appdir }}/usr/.crates.toml" "{{ telescope_appdir }}/usr/.crates2.json"; \
    fi

    # Telescope stuff
    install -Dm755 "telescope/scripts/telescope" "{{ telescope_appdir }}/usr/bin/telescope"
    install -Dm755 "telescope/scripts/telescope_startup" "{{ telescope_appdir }}/usr/libexec/telescope_startup"
    install -Dm755 "telescope/scripts/AppRun" "{{ telescope_appdir }}/AppRun"
    install -Dm644 "telescope/data/org.stardustxr.Telescope.desktop" "{{ telescope_appdir }}/org.stardustxr.Telescope.desktop"
    install -Dm644 "telescope/data/org.stardustxr.Telescope.png" "{{ telescope_appdir }}/org.stardustxr.Telescope.png"

appimage-telescope appimage=("Telescope-" + arch() + ".AppImage"): appdir-telescope
    #!/usr/bin/env sh
    set -eu
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    curl -sSLf -o "$tmp/appimagetool" "https://github.com/AppImage/appimagetool/releases/download/{{ appimagetool_version }}/appimagetool-{{ arch() }}.AppImage"
    curl -sSLf -o "$tmp/runtime" "https://github.com/AppImage/type2-runtime/releases/download/{{ appimage_runtime_version }}/runtime-{{ arch() }}"
    printf '%s  %s\n' "{{ appimagetool_sha256 }}" "$tmp/appimagetool" "{{ appimage_runtime_sha256 }}" "$tmp/runtime" | sha256sum -c
    chmod +x "$tmp/appimagetool"
    # without --runtime-file appimagetool downloads the unpinned continuous runtime
    "$tmp/appimagetool" --runtime-file "$tmp/runtime" "{{ telescope_appdir }}" "{{ appimage }}"

test-telescope *args: appdir-telescope
    APPDIR="{{ telescope_appdir }}" "{{ telescope_appdir }}/AppRun" {{ args }}

update:
    git submodule foreach 'git checkout "$(git -C "$toplevel" config -f .gitmodules --get submodule."$name".branch || echo main)" && git pull'

prefix-install: build
    {{ just }} rootdir="{{ justfile_directory() / 'prefix' }}" install
    [ -e "{{ justfile_directory() }}/startup.sh" ] || install -Dm755 "telescope/scripts/telescope_startup" "{{ justfile_directory() }}/startup.sh"

[no-exit-message]
prefix-run *args:
    PATH="{{ prefix_dir / 'bin' }}:{{ env('PATH') }}" \
    XDG_DATA_DIRS="{{ prefix_dir / 'share' }}:{{ env('XDG_DATA_DIRS', '/usr/local/share:/usr/share') }}" \
    STARDUST_RES_PREFIXES="{{ prefix_dir / 'share' }}:{{ env('STARDUST_RES_PREFIXES', '/usr/share') }}" \
    {{ prefix_dir / 'bin' / 'stardust-xr-server' }} -o 6 -e {{ justfile_directory() / 'startup.sh' }} {{ args }}

clean:
    rm -rf org.stardustxr.Armillary/target
    rm -rf org.stardustxr.Atmosphere/target
    rm -rf org.stardustxr.BlackHole/target
    rm -rf org.stardustxr.Comet/target
    rm -rf org.stardustxr.Flatland/target
    rm -rf org.stardustxr.Gravity/target
    rm -rf org.stardustxr.NonSpatialInput/target
    rm -rf org.stardustxr.Protostar/target
    rm -rf org.stardustxr.SolarSailer/target
    rm -rf org.stardustxr.Server/target
    rm -rf org.stardustxr.WaylandService/target
    rm -rf org.stardustxr.PalmLauncher/target
