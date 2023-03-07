{ config, pkgs, ... }:

{
  imports = [
    ../../common/workstation.nix
    ../../common/mpd.nix
    ../../common/networkmanager.nix
    ../../common/borgmatic.nix
    ./ups.nix
    ./hardware-configuration.nix
  ];

  users.motd = ''

            ______             ______
              o__.‘\_.-"V"-._/’.__o
            _O/  \.'_\”   “/_`./  \O_
                 //           \\
    Welcome     |>             <|
      to        ||             ||
    stargate!   ||_           _||
                 \/\         /\/
                  `._/|____|\_.'
                     `-....-'
                  --//::::::\\--
                  |//::::::::\\|
                 \//::::::::::\\/
                \//::::::::::::\\/
         /     \ |--------------| /      \
    /-||-\    \  /……………………………………\  /     /-||-\
    |_//_|   \  |----------------|  /    |_\\_|
     //|    \                        /     |\\
       |   ////////////////////////////    |

  '';

  my.borgmatic = {
    enable = true;
    username = "tw8vh7jl";
    hostname = "tw8vh7jl.repo.borgbase.com";
    directories = ["/home" "/root" "/secrets"];
    excludes = ["/root/.cache" "/home/*/.cache" "*/steamapps"];
  };
  my.zfs.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "stargate";
  networking.hostId = "180b60c6";

  services.openssh.ports = [ 22 9999 ];

  environment.etc.crypttab.text = ''
    greenCrypt UUID=704eca58-8f57-4f53-989e-56511d731366 /secrets/green.key luks
  '';

  fileSystems."/games" = {
    device = "/dev/Green/games";
    fsType = "ext4";
  };

  fileSystems."/stuff" = {
    device = "/dev/Green/main";
    fsType = "ext4";
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

  # my.libvirtd.interfaces.primary = "enp39s0";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
