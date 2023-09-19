{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/borgmatic.nix
    ../../common/workstation.nix
    ../../common/laptop.nix
    ../../common/networkmanager.nix
    ../../common/zfs.nix
  ];

  users.motd = ''

      ____
     /___/\_
    _\   \/_/\__   Welcome to icarus.
  __\       \/_/\
  \   __    __ \ \
 __\  \_\   \_\ \ \   __
/_/\\   __   __  \ \_/_/\
\_\/_\__\/\__\/\__\/_\_\/
   \_\/_/\       /_\_\/
      \_\/       \_\/

  '';


  my.zfs.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  swapDevices = [
    {
      randomEncryption = {
        enable = true;
	allowDiscards = true;
      };
      device = "/dev/nvme0n1p3";
      discardPolicy = "pages";
    }
  ];

  # services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.displayManager.defaultSession = "gnome";
  # services.power-profiles-daemon.enable = true;
  # services.tlp.enable = false;
  # qt5.platformTheme = "gnome";

  networking.hostName = "icarus";
  networking.hostId = "97d3b747";
  networking.bridges.br15.interfaces = [];
  systemd.services.br15-netdev.wantedBy = ["libvirtd.service"];

  my.tmp-as-tmpfs.enable = false;

  # Same repository as stargate.
  my.borgmatic = {
    enable = true;
    username = "tw8vh7jl";
    hostname = "tw8vh7jl.repo.borgbase.com";
    directories = ["/home" "/root" "/secrets"];
    excludes = ["/root/.cache" "/home/*/.cache" "*/steamapps"];
    calendar = [ "*-*-* 17:00:00" ];
  };

  environment.systemPackages = with pkgs; [ (tic-80.override { withPro = true; }) ];
}
