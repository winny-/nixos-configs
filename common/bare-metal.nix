{ lib, config, ... }:
with lib;
{
  services.smartd.enable = mkDefault true;
  services.irqbalance.enable = mkDefault true;
  hardware.rasdaemon.enable = mkDefault true;
  services.fwupd.enable = mkDefault true;
  boot.loader.grub.memtest86.enable = mkDefault config.boot.loader.grub.enable;
}
