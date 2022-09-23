{ lib, ... }:
with lib;
{
  services.irqbalance.enable = true;
  hardware.rasdaemon.enable = mkDefault true;
  services.fwupd.enable = mkDefault true;
}
