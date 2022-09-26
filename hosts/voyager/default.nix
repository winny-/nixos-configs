{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/workstation.nix
    ../../common/laptop.nix
    ../../common/networkmanager.nix
  ];

  environment.systemPackages = [ pkgs.jhmod ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "voyager";
  networking.hostId = "c989c6ac";
}
