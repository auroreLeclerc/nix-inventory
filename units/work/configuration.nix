{ ... }:
{
  imports = [
    {
      home-manager.users.dawn = {
        imports = [
          ../../modules/gaming/gaming.home.nix
          ../../modules/vscode.home.nix
        ];
        home.stateVersion = "26.05";
      };
    }
  ];
  config = {
    networking.hostName = "work";
    users.users.dawn = {
      name = "auurore";
      home = "/Users/auurore";
    };
    system.stateVersion = 7;
  };
}
