{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/workstation.nix
    ../../common/laptop.nix
    ../../common/networkmanager.nix
  ];

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
        subvolume = "home";
        snapshot_dir = ".snapshots";
      };
    };
  };

  services.btrbk.instances."weekly" = {
    onCalendar = "weekly";
    settings = {
      snapshot_preserve_min = "30d";
      volume."/" = {
        subvolume = "home";
        snapshot_dir = ".snapshots";
      };
    };
  };

  services.btrbk.instances."frequently" = {
    onCalendar = "*:0/15";
    settings = {
      snapshot_preserve_min = "1d";
      volume."/" = {
        subvolume = "home";
        snapshot_dir = ".snapshots";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    compsize
  ];

  networking.hostName = "icarus";
  networking.hostId = "97d3b747";

  my.tmp-as-tmpfs.enable = false;
}
