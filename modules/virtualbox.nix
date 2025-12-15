{ pkgs, unstablePkgs, ... }: {
	config = {
		specialisation."Capture The Flag".configuration = {
			virtualisation.virtualbox.host.enable = true;
			users.extraGroups.vboxusers.members = [ "dawn" ];
			environment.systemPackages = with pkgs; [ tor nmap torsocks unstablePkgs.wpscan nikto kdePackages.konversation ];
		};
	};
}