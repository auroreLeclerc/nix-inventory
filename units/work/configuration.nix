{ ... }:
{
  imports = [
    {
      home-manager.users.dawn = {
        imports = [ ];
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
    system.stateVersion = 5;
  };
}
