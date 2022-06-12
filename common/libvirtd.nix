{ config, pkgs, ... }:
{
  users.users.winston.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd.enable = true;
}
