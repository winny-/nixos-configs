{ lib, ... }:
{
  services.tlp = {
    enable = true;
    settings = with lib; {
      # See https://linrunner.de/tlp/settings/index.html
      START_CHARGE_THRESH_BAT0 = mkDefault 75;
      STOP_CHARGE_THRESH_BAT0 = mkDefault 80;
    };
  };

  services.thermald.enable = true;
}
