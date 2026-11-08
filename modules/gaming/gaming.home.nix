{ pkgs, ... }:
{
  programs.prismlauncher = {
    enable = true;
    config.java = {
      path = "${pkgs.jdk}/bin/java";
      mem = {
        min = 4096;
        max = 4096 * 3;
      };
    };
    instances.main = {
      minecraft.version = "1.21.1";
      icon = "creeper";
      group = "Releases";

      mod = {
        loader = {
          name = "neoforge";
          version = "21.1.249";
        };
        mods = [ ];
      };
    };
  };
}
