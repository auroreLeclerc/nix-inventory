{ pkgs, ... }:
{ #TODO: https://docs.hercules-ci.com/arion/ & move networking elsewhere
	networking = {
		networkmanager.enable = true;
		firewall = {
			enable = true;
			allowedUDPPorts = [ 51820 ];
		};
		nat = {
			enable = true;
			externalInterface = "enp10s0";
		};
	};
	virtualisation.docker.rootless = {
		enable = true;
		setSocketVariable = true;
	};
	environment.systemPackages = (with pkgs; [ docker-compose ]);
}