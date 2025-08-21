{ ... }: {
	config = {
		services.podman = {
			enable = true;
			autoUpdate.enable = true;
			networks.docker-like = {
				description = "Docker compatibilty (internal DNS resolution)";
				driver = "bridge";
				subnet = "172.18.0.0/24";
				gateway = "172.18.0.1";
			};
		};
	};
}