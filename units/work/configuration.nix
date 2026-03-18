{ ... }:
{
  imports = [
    {
      home-manager.users.auurore = {
        imports = [ ];
        home.stateVersion = "25.05";
      };
    }
  ];
  config = {
    networking.hostName = "work";
    system.stateVersion = 5;
  };
}
