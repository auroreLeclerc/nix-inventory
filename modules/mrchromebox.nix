{ pkgs, inputs, ... }:
let
  mrchromebox-firmware-util = pkgs.buildFHSEnv {
    name = "mrchromebox-firmware-util";
    targetPkgs =
      pkgs: with pkgs; [
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
    runScript = pkgs.writeShellScript "mrchromebox" ''
      export script_dir="${inputs.mrchromebox-scripts}"
      export use_local="y"
      bash ${inputs.mrchromebox-scripts}/firmware-util.sh
    '';
  };
in
{
  environment.systemPackages = [ mrchromebox-firmware-util ];
}
