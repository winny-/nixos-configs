{ config, pkgs, ... }:

{
  fonts = {
    enableDefaultFonts = true;
    fontconfig = {
      defaultFonts = {
        serif = [ "Go" ];
	      monospace = [ "Go Mono" ];
	      sansSerif = [ "Roboto" ];
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
    ];
  };
}
