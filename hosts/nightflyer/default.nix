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

  # nix-build falls back to /run/users/0 - tmpfs on a memory constrained
  # system is no good.
  environment.variables.TMPDIR = "/tmp";

  # Spams logs with warnings.  Journal log I/O not worth the benefit.
  hardware.rasdaemon.enable = false;

  system.stateVersion = "22.05";

}

