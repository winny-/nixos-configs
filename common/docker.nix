{ config, pkgs, lib, ... }:
{
  users.users.winston.extraGroups = [ "docker" ];
  environment.systemPackages = with pkgs; [ docker-compose ];
  virtualisation.docker.enable = true;

  # Upgrading to 23.11 broke my old docker installs on some hosts that use ZFS.
  virtualisation.docker.storageDriver = lib.mkDefault "devicemapper";
}
