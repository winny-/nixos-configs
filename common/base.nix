{ config, pkgs, lib, options, ... }:
with lib; {
  imports = [
    ../package-overrides
    ./mosh.nix
  ];

  fileSystems."/backup" = {
    device = "/dev/disk/by-uuid/fb07e0e8-4cf1-4a53-a5ed-2330c6602525";
    fsType = "ext4";
    options = [ "noauto" ];
  };

  fileSystems."/multimedia" = {
    device = "//silo.lan/multimedia";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "nofail"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "user=guest"
      "password=password"
      "ro"
    ];
  };

  fileSystems."/tmp" = {
    fsType = "tmpfs";
    options = [
      "noatime"
      "mode=1777"
      "size=4G"
    ];
  };

  services.zfs.autoSnapshot.enable = mkDefault config.boot.zfs.enabled;
  time.timeZone = mkDefault "America/Chicago";

  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
      experimental-features = nix-command flakes
  '';

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.winston = {
    isNormalUser = true;
    extraGroups = [
      "wheel"  # Enable ‘sudo’ for the user.
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.irqbalance.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_ecdsa_key";
        type = "ecdsa";
      }
    ];
  };

  networking.firewall.rejectPackets = true;

  hardware.rasdaemon.enable = mkDefault true;
  services.fwupd.enable = mkDefault true;

  environment.systemPackages = with pkgs; [
    tmux
    screen  # Serial terminals

    coreutils  # Avoid busybox rm and gain more features.
    unixtools.procps  # Avoid busybox ps and watch.
    usbutils  # Avoid busybox lsusb

    nano
    ed
    vim
    mg
    # This will override entry in graphical.nix - so disable.  Add emacs-nox where applicable.
    # emacs-nox
    ispell  # Emacs needs this for flyspell.

    git
    git-lfs

    lynx
    links2

    neofetch

    rlwrap
    tree
    keychain
    sshfs
    pv
    pwgen
    ripgrep
    file
    parted
    smartmontools

    powertop

    htop
    glances
    mc
    nwipe
    ddrescue
    cryptsetup  # Sometimes I manually mount stuff so ensure cryptsetup is
                # always available
    gnupg
    acpi
    sysstat
    dstat
    stress-ng
    rsync
    lsof
    lnav
    entr
    lm_sensors
    pciutils
    hwinfo

    bsdgames
    nethack

    nixos-option
    nix-index

    direnv
    nix-direnv

    hw-probe

    man-pages
    man-pages-posix
  ];
}
