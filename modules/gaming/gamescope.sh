# shellcheck shell=bash
set -xeuo pipefail

# https://github.com/flightlessmango/MangoHud#gamescope
# https://wiki.nixos.org/wiki/Steam

gamescopeArgs=(
	--adaptive-sync # Variable Refresh Rate
	--xwayland-count 2
	--mangoapp # performance overlay
	# --rt https://github.com/NixOS/nixpkgs/issues/523427
	--steam
	# --hdr-enabled
	# --hdr-itm-enabled # SDR->HDR
)
steamArgs=(
	-pipewire-dmabuf
	-gamepadui
	-steamdeck
	-steamos3
)
mangoConfig=(
	cpu_temp
	gpu_temp
	ram
	vram
)
mangoVars=(
	MANGOHUD_CONFIG="$(IFS=,; echo "${mangoConfig[*]}")"
)
steamVars=(
	STEAM_MULTIPLE_XWAYLANDS=1
	STEAM_GAMESCOPE_VRR_SUPPORTED=1
)

export "${mangoVars[@]}" "${steamVars[@]}"
exec gamescope "${gamescopeArgs[@]}" -- steam "${steamArgs[@]}"
