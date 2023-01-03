{ config, pkgs, ... }:
{
  users.users.winston.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd.enable = true;
  security.polkit.enable = true;  # Required by libvirtd.
}
