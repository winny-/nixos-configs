{ config, pkgs, ... }:
{
  imports = [
    ../../common/graphical.nix
    ../../common/laptop.nix
    ../../common/networkmanager.nix
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "voyager";
  networking.hostId = "c989c6ac";
}
