{
  pkgs,
  lib,
  eden,
  SDL2,
  sdl3,
  qt6,
  spirv-tools,
  eglantineSrc,
  name ? "eglantine",
}:

let
  zstdSrc = pkgs.fetchFromGitHub {
    owner = "facebook";
    repo = "zstd";
    rev = "33618c8";
    hash = "sha256-UP99PUq8N+fmU972Jxim4f9u//T+4hRW+wuTZzWg3uI=";
  };
  zbicSrc = pkgs.fetchFromGitHub {
    owner = "kinnay";
    repo = "zbic";
    rev = "11b08f2712264bbed731545085cbd9702096ceb7";
    hash = "sha256-pHvxa1gkUvQo6mUgmLWtj1kcu01BLdGmttZyb8ZAj/o=";
  };
  reshadeSrc = pkgs.fetchFromGitHub {
    owner = "crosire";
    repo = "reshade";
    tag = "v6.8.0";
    hash = "sha256-K6QC7CLqy8M318n9WbuqGvcRF9g9abvDD/xbr7T+nXo=";
  };
in
eden.overrideAttrs (
  _: oldAttrs: {
    pname = name;
    version = "0-unstable-${eglantineSrc.shortRev or "dirty"}";
    src = eglantineSrc;

    buildInputs = (builtins.filter (p: p != SDL2) oldAttrs.buildInputs) ++ [
      sdl3
      qt6.qt5compat
      spirv-tools
    ];

    cmakeFlags = oldAttrs.cmakeFlags ++ [
      (lib.cmakeBool "ENABLE_WERROR" false)
      (lib.cmakeFeature "zstd_CUSTOM_DIR" "${zstdSrc}")
      (lib.cmakeBool "zbic_FORCE_BUNDLED" true)
      (lib.cmakeFeature "zbic_CUSTOM_DIR" "${zbicSrc}")
      (lib.cmakeBool "reshade_FORCE_BUNDLED" true)
      (lib.cmakeFeature "reshade_CUSTOM_DIR" "${reshadeSrc}")
    ];

    postInstall = "";
    postConfigure = "";
    doCheck = false;
  }
)
