{
  description = "Meta-flake bundling all Stardust XR components";

  nixConfig = {
    extra-substituters = [
        "https://stardustxr.cachix.org"
    ];
    extra-trusted-public-keys = [
      "stardustxr.cachix.org-1:mWSn8Ap2RLsIWT/8gsj+VfbJB6xoOkPaZpbjO+r9HBo="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # submodules
    armillary.url = "github:StardustXR/armillary";
    atmosphere.url = "github:StardustXR/atmosphere";
    black-hole.url = "github:StardustXR/black-hole";
    comet.url = "github:StardustXR/comet";
    flatland.url = "github:StardustXR/flatland";
    gravity.url = "github:StardustXR/gravity";
    non-spatial-input.url = "github:StardustXR/non-spatial-input";
    protostar.url = "github:StardustXR/protostar";
    solar-sailer.url = "github:StardustXR/solar-sailer";

    # the server
    server = {
      url = "github:StardustXR/server";
      inputs.flatland.follows = "flatland";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = lib.genAttrs supportedSystems;
      pkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});

      componentInputs = {
        inherit (inputs)
          armillary
          atmosphere
          black-hole
          comet
          flatland
          gravity
          non-spatial-input
          protostar
          solar-sailer
          ;
        stardust-xr-server = inputs.server;
      };

      withDesktopData =
        pkgs: name: flake:
        let
          pkg = flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        pkgs.symlinkJoin {
          name = "${name}-${pkg.version or "unstable"}";
          paths = [ pkg ];
          postBuild = ''
            for f in ${flake}/data/*.desktop; do
              [ -e "$f" ] || continue
              install -Dm0644 "$f" "$out/share/applications/$(basename "$f")"
            done
            for f in ${flake}/data/*.metainfo.xml; do
              [ -e "$f" ] || continue
              install -Dm0644 "$f" "$out/share/metainfo/$(basename "$f")"
            done
          '';
          passthru.unwrapped = pkg;
          meta = (pkg.meta or { }) // {
            mainProgram = pkg.meta.mainProgram or pkg.pname or name;
          };
        };

      componentsFor =
        system: lib.mapAttrs (withDesktopData nixpkgs.legacyPackages.${system}) componentInputs;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor.${system};
          components = componentsFor system;

          # One store path containing every component's bin/ and share/.
          # This is "the bundle" — the Nix equivalent of `just prefix-install`.
          stardust-xr = pkgs.symlinkJoin {
            name = "stardust-xr";
            paths = lib.attrValues components;
            meta.description = "All Stardust XR components in one prefix";
          };

          # telescope_startup, with every binary resolved from the bundle.
          telescope-startup = pkgs.writeShellApplication {
            name = "telescope_startup";
            runtimeInputs = [
              stardust-xr
              pkgs.xwayland-satellite
            ];
            text = ''
              xwayland-satellite :10 &
              export DISPLAY=:10

              flatland &
              gravity -- 0 0.0 -0.5 hexagon_launcher &
              black-hole &

              WAYLAND_DISPLAY="''${FLAT_WAYLAND_DISPLAY:-}" manifold | simular &
            '';
          };

          telescope-bin = pkgs.writeShellApplication {
            name = "telescope";
            runtimeInputs = [ stardust-xr ];
            text = ''
              # xkbcommon-rs defaults to /usr/share/X11/xkb, which doesn't exist on NixOS
              export XKB_CONFIG_ROOT="''${XKB_CONFIG_ROOT:-${pkgs.xkeyboard-config}/share/X11/xkb}"
              exec stardust-xr-server -o 6 -e ${telescope-startup}/bin/telescope_startup "$@"
            '';
          };
        in
        components
        // {
          inherit stardust-xr;
          default = stardust-xr;

          # Full Telescope session: launcher + startup script + desktop entry,
          # the same layout `just appdir-telescope` produces.
          telescope = pkgs.symlinkJoin {
            name = "telescope";
            paths = [
              telescope-bin
              telescope-startup
              stardust-xr
            ];
            postBuild = ''
              install -Dm0644 ${./telescope/data/org.stardustxr.Telescope.desktop} \
                $out/share/applications/org.stardustxr.Telescope.desktop
              install -Dm0644 ${./telescope/data/org.stardustxr.Telescope.metainfo.xml} \
                $out/share/metainfo/org.stardustxr.Telescope.metainfo.xml
              install -Dm0644 ${./telescope/data/org.stardustxr.Telescope.png} \
                $out/share/icons/hicolor/512x512/apps/org.stardustxr.Telescope.png
            '';
            meta = {
              description = "StardustXR based OpenXR overlay";
              mainProgram = "telescope";
            };
          };
        }
      );

      overlays.default =
        final: _prev:
        componentsFor final.stdenv.hostPlatform.system
        // {
          stardust-xr = self.packages.${final.stdenv.hostPlatform.system}.stardust-xr;
          telescope = self.packages.${final.stdenv.hostPlatform.system}.telescope;
        };

      apps = forAllSystems (system: {
        default = self.apps.${system}.telescope;
        telescope = {
          type = "app";
          program = lib.getExe self.packages.${system}.telescope;
        };
        stardust-xr-server = {
          type = "app";
          program = "${self.packages.${system}.stardust-xr-server}/bin/stardust-xr-server";
        };
      });

      # Only some components define checks; `or { }` keeps `nix flake check`
      # working while the submodule flakes are in flux.
      checks = forAllSystems (
        system:
        lib.foldl' lib.mergeAttrs { } (
          lib.mapAttrsToList (
            name: flake: lib.mapAttrs' (k: lib.nameValuePair "${name}-${k}") (flake.checks.${system} or { })
          ) componentInputs
        )
        // {
          bundle = self.packages.${system}.stardust-xr;
          telescope = self.packages.${system}.telescope;
        }
      );

      devShells = forAllSystems (system: {
        default = pkgsFor.${system}.mkShell {
          inputsFrom = map (p: p.unwrapped) (lib.attrValues (componentsFor system));
          packages = with pkgsFor.${system}; [
            just
            cargo
            rustc
            rust-analyzer
            xwayland-satellite
          ];
        };
      });

      formatter = forAllSystems (system: pkgsFor.${system}.nixfmt-rfc-style);
    };
}
