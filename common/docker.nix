{ config, pkgs, ... }:
{
  users.users.winston.extraGroups = [ "docker" ];
  environment.systemPackages = with pkgs; [ docker-compose ];
  virtualisation.docker.enable = true;
}
