{ pkgs, lib, ... }:
{
  services.mpd = with lib; {
    enable = mkDefault true;
    musicDirectory = mkDefault "/multimedia/music";
    extraConfig = ''
      audio_output {
        type "pulse"
        name "Local Pulseaudio"
        server "127.0.0.1" # add this line - MPD must connect to the local sound server
      }
    '';
  };
  hardware.pulseaudio.extraConfig = "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1";

  environment.systemPackages = with pkgs; [
    ncmpcpp
    mpc-cli
  ];
}
