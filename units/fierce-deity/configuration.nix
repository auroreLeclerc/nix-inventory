# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ inputs, pkgs, ... }:
{
  imports = [
    ../../modules/kde/kde.nix
    ../../modules/gaming/gaming.nix
    ../../modules/workstation.nix
    ../../modules/zfs.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    {
      home-manager.users.dawn = {
        imports = [
          ../../modules/podman/workbench.home.nix
          ../../modules/firefox.home.nix
          ../../modules/kde/kde-desktop.home.nix
          ../../modules/flatpak.home.nix
        ];
      };
    }
  ];
  config = {
    networking = {
      hostId = "007f0200";
      hostName = "fierce-deity";
    };
    hardware.graphics.extraPackages =
      let
        amdvlk-run =
          with inputs.oldpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
          writeShellScriptBin "amdvlk-run" ''
            export VK_DRIVER_FILES="${amdvlk}/share/vulkan/icd.d/amd_icd64.json:${
              inputs.oldpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.driversi686Linux.amdvlk
            }/share/vulkan/icd.d/amd_icd32.json"
            exec "$@"
          '';
      in
      with inputs.oldpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      [
        amdvlk
        amdvlk-run
      ];
    hardware.graphics.extraPackages32 = [
      inputs.oldpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.driversi686Linux.amdvlk
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "26.05"; # Did you read the comment?
  };
}
