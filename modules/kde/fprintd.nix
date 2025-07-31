{ lib, ... }:
{
  config = {
    security.pam.services = {
      sddm.text = lib.mkBefore "auth  sufficient pam_unix.so try_first_pass  likeauth  nullok"; # https://wiki.archlinux.org/title/Fprint#Login_configuration;
      sudo.fprintAuth = false;
    };
  };
}
