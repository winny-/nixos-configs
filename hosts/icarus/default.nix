{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/workstation.nix
    ../../common/laptop.nix
    ../../common/networkmanager.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.NixCrypt = {
    device = "/dev/disk/by-uuid/7c75aa56-138e-4d5e-b5d4-62a666260b5f";
    preLVM = true;
    allowDiscards = true;
  };

  # services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.displayManager.defaultSession = "gnome";
  # services.power-profiles-daemon.enable = true;
  # services.tlp.enable = false;
  # qt5.platformTheme = "gnome";

  networking.hostName = "icarus";
  networking.hostId = "97d3b747";
}
