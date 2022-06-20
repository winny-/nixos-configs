{ pkgs, ... }:
{
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    gutenprintBin
    postscript-lexmark
  ];
}
