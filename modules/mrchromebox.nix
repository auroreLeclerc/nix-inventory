{ pkgs, ... }:
let
  mrchromebox-firmware-util = pkgs.buildFHSEnv {
    name = "mrchromebox-firmware-util";
    targetPkgs =
      pkgs: with pkgs; [
        curl
        cacert
        dmidecode
        flashrom
        pciutils
        usbutils
        util-linux
        e2fsprogs
        gnutar
        p7zip
        coreutils
        gnugrep
        gnused
        gawk
        kmod
        systemd
        bash
        ncurses
        glib
        libusb1
        zlib
        stdenv.cc.cc.lib
      ];
    runScript = pkgs.writeShellScript "mrchromebox" "cd; curl -LOf https://mrchromebox.tech/firmware-util.sh && sudo bash firmware-util.sh";
  };
in
{
  environment.systemPackages = [ mrchromebox-firmware-util ];
}
