{ config, pkgs, ... }:

{
  imports = [
      ../../common/winston.nix
  ];
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];

  networking.hostName = "stargate";
  networking.hostId = "180b60c6";

  services.zfs.autoSnapshot.enable = true;
  services.openssh.ports = [ 9999 ];

  environment.etc.crypttab = {
    enable = true;
    text = ''
      greenCrypt UUID=704eca58-8f57-4f53-989e-56511d731366 /secrets/green.key luks
    '';
  };

  fileSystems."/games" = {
    device = "/dev/Green/games";
    fsType = "ext4";
  };

  fileSystems."/stuff" = {
    device = "/dev/Green/main";
    fsType = "ext4";
  };

  fileSystems."/backup" = {
    device = "/dev/disk/by-uuid/fb07e0e8-4cf1-4a53-a5ed-2330c6602525";
    fsType = "ext4";
    options = [ "noauto" ];
  };

  fileSystems."/gentoo" = {
    device = "/dev/Green/Gentoo_Root";
    fsType = "ext4";
    options = [ "ro" ];
  };

  fileSystems."/gentoo/home" = {
    device = "/dev/Green/Gentoo_Home";
    fsType = "ext4";
    options = [ "ro" ];
  };

  fileSystems."/gentoo/boot" = {
    device = "/dev/Green/Gentoo_Boot";
    fsType = "vfat";
    options = [ "ro" ];
  };

  fileSystems."/multimedia" = {
    device = "//silo.lan/multimedia";
    fsType = "cifs";
    options = [
      "x-systemd.automount" "nofail" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s" "user=guest" "password=password" "ro"
    ];
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  
  networking.useDHCP = false;
  networking.interfaces.enp39s0.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;
 

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
