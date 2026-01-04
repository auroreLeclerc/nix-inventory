{ lib, ... } : let 
	const = import ./const.nix;
in {
	inherit const;
	impureSopsReading = (location:
		assert builtins.isString location;
		if lib.inPureEvalMode then
			builtins.trace "💁🏻‍♀️ No impure flag, can't eval secrets." ""
		else if ! builtins.pathExists const.AGE_KEY_FILE then
			builtins.trace "💁🏻‍♀️ No sops age keys found, can't eval secrets." ""
		else if ! builtins.pathExists location then
			builtins.trace "💁🏻‍♀️ Secrets aren't decrypted on first run." ""
		else
			(builtins.readFile location)
	);
	checkSupportedVersion = (version:
		assert builtins.isString version;
		let 
			infra = import (builtins.fetchurl { # FIXME: how to update the SRI sha256 each 6months
				url = "https://raw.githubusercontent.com/NixOS/infra/refs/heads/main/channels.nix";
				sha256 = "sha256-MBHWO7AUrNMD0RCdz5qyoII24c2FoHNFkL2uqPG5cIo=";
			});
		in {
			"rolling" = builtins.trace "💁🏻‍♀️ You sure about that ?" true;	
			"stable" = true;
			"deprecated" = builtins.trace "🙎🏻‍♀️ Nixos ${version} is deprecated !" true;
			"unmaintained" = builtins.abort "🙅🏻‍♀️ Nixos ${version} is End Of Life !";
		}.${infra.channels."nixos-${version}".status}
	);
	consoleWarn = (control: log:
		assert builtins.isBool control;
		assert builtins.isString log;
		if !control then # ugly
			builtins.trace "🙎🏻‍♀️ ${log}" control	
		else
			control
	);
}
