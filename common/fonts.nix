{ config, pkgs, ... }:

{
  fonts = {
    enableDefaultFonts = true;
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        monospace = [ "mononoki" ];
        sansSerif = [ "Noto Sans" ];
      };
    };
    fonts = with pkgs; [
      roboto
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      dina-font
      proggyfonts
      go-font
      mononoki
      droid-fonts
    ];
  };
}
