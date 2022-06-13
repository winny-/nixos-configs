{ config, pkgs, ... }:
{
  imports = [ ../../common/winston.nix ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "voyager";
  networking.hostId = "c989c6ac";
  networking.networkmanager.enable = true;
}
