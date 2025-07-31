{ pkgs, ... }: {
	config = {
		specialisation."Capture The Flag".configuration = {
			virtualisation.virtualbox.host.enable = true;
			users.extraGroups.vboxusers.members = [ "dawn" ];
			boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # https://discourse.nixos.org/t/issue-with-virtualbox-in-24-11/57607/2
			environment.systemPackages = with pkgs; [ tor nmap torsocks kdePackages.konversation ];
		};
	};
}