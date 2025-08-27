{ pkgs, ... } : {
	config = {
		systemd.user.services.mprisence = {
			Unit.Description = "Discord Rich Presence for MPRIS media players";
			Service = {
				Type = "simple";
				ExecStart = "${pkgs.mprisence}/bin/mprisence";
				Restart = "always";
				RestartSec = 10;
				Environment = ["RUST_LOG=info" "RUST_BACKTRACE=1"];
				ReadWritePaths = ["%h/.config/mprisence" "%h/.cache/mprisence"];
			};
			Install.WantedBy = ["default.target"];
		};
		home = {
			packages = [ pkgs.mprisence ];
			file.mprisence = {
				text = builtins.readFile ./mprisence.toml;
				target = ".config/mprisence/config.toml";
			};
		};
	};
}