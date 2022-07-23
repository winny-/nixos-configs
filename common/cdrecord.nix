{ pkgs, ... }:
{
  users.users.winston.extraGroups = [ "cdrom" ];
  environment.systemPackages = with pkgs; [
    cdrkit
  ];
}
