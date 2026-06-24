{
  pkgs,
  ...
}:
{
  config = {
    specialisation."Virtualbox".configuration = {
      virtualisation.virtualbox.host.enable = true;
      users.extraGroups.vboxusers.members = [ "dawn" ];
      environment.systemPackages = with pkgs; [
        tor
        nmap
        torsocks
        wpscan
        nikto
        kdePackages.konversation
      ];
    };
  };
}
