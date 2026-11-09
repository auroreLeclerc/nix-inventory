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
  home.file.minecraft = {
    source = builtins.toFile "accounts.json" (
      builtins.toJSON {
        accounts = [
          {
            entitlement = {
              canPlayMinecraft = true;
              ownsMinecraft = true;
            };
            msa-client-id = "";
            type = "MSA";
          }
          {
            active = true;
            profile = {
              capes = [ ];
              id = "0c79d88a112537a0a302f01afa6bc94a";
              name = "Horror";
              skin = {
                id = "";
                url = "";
                variant = "";
              };
            };
            type = "Offline";
            ygg = {
              extra = {
                clientToken = "8be89b1112474b5fb8f061699ff41bda";
                userName = "Horror";
              };
              iat = 1738858981;
              token = "0";
            };
          }
        ];
        formatVersion = 3;
      }
    );
    target = ".local/share/PrismLauncher/accounts.json";
  };
}
