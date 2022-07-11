{ pkgs, ... }:
{
  users.users.winston.extraGroups = [ "wireshark" ];
  programs.wireshark.enable = true;
  environment.systemPackages = [ pkgs.wireshark ];
}
