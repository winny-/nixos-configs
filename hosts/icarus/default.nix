{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/borgmatic.nix
    ../../common/workstation.nix
    ../../common/laptop.nix
    ../../common/networkmanager.nix
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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.NixCrypt = {
    device = "/dev/disk/by-uuid/7c75aa56-138e-4d5e-b5d4-62a666260b5f";
    preLVM = true;
    allowDiscards = true;
  };

  # services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.displayManager.defaultSession = "gnome";
  # services.power-profiles-daemon.enable = true;
  # services.tlp.enable = false;
  # qt5.platformTheme = "gnome";

  # BTRFS snapshots inspired by
  # https://dataswamp.org/~solene/2022-10-07-nixos-btrfs-continuous-snapshots.html

  services.btrbk.instances."daily" = {
    onCalendar = "daily";
    settings = {
      snapshot_preserve_min = "7d";
      volume."/" = {
        subvolume.home = {
          snapshot_name = "daily";
        };
        snapshot_dir = ".snapshots";
      };
    };
  };

  services.btrbk.instances."weekly" = {
    onCalendar = "weekly";
    settings = {
      snapshot_preserve_min = "30d";
      volume."/" = {
        subvolume.home = {
          snapshot_name = "weekly";
        };
        snapshot_dir = ".snapshots";
      };
    };
  };

  services.btrbk.instances."frequently" = {
    onCalendar = "*:0/15";
    settings = {
      snapshot_preserve_min = "1d";
      volume."/" = {
        subvolume.home = {
          snapshot_name = "frequently";
        };
        snapshot_dir = ".snapshots";
      };
    };
  };

  networking.hostName = "icarus";
  networking.hostId = "97d3b747";
  networking.bridges.br15.interfaces = [];
  systemd.services.br15-netdev.wantedBy = ["libvirtd.service"];

  my.tmp-as-tmpfs.enable = false;
  my.btrfs.enable = true;

  # Same repository as stargate.
  my.borgmatic = {
    enable = true;
    username = "tw8vh7jl";
    hostname = "tw8vh7jl.repo.borgbase.com";
    directories = ["/home" "/root" "/secrets"];
    excludes = ["/root/.cache" "/home/*/.cache" "*/steamapps"];
    calendar = [ "*-*-* 17:00:00" ];
  };

}
