{ ... }:
{
  networking.networkmanager.enable = true;
  users.users.winston.extraGroups = [ "networkmanager" ];
}
