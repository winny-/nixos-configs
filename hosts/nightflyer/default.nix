{ config, pkgs, ... }:
{
  imports =
    [
      ../../common/base.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.kernelParams = [ "forcepae" ];
  boot.loader.grub.device = "/dev/sda";

  boot.initrd.luks.devices.nixosCrypt = {
    device = "/dev/sda2";
    allowDiscards = true;
    preLVM = true;
  };

  networking.hostName = "nightflyer";
  time.timeZone = "America/Chicago";

  system.stateVersion = "22.05";

}

