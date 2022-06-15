{ lib, ... }:
{
  services.tlp.enable = true;

  # See https://linrunner.de/tlp/settings/index.html
  services.tlp.settings = with lib; {
    START_CHARGE_THRESH_BAT0 = mkDefault 75;
    STOP_CHARGE_THRESH_BAT0 = mkDefault 80;
  };
}
