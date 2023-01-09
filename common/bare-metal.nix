{ lib, config, ... }:
with lib;
{
  services.irqbalance.enable = true;
  hardware.rasdaemon.enable = mkDefault true;
  services.fwupd.enable = mkDefault true;
  boot.loader.grub.memtest86.enable = mkDefault config.boot.loader.grub.enable;
}
