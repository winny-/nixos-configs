{ config, pkgs, ... }:
{
  imports = [
    ../package-overrides
  ];

  nixpkgs.config.allowUnfree = true;

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

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  hardware.rasdaemon.enable = true;

  environment.systemPackages = with pkgs; [
    tmux
    screen  # Serial terminals

    coreutils  # Avoid busybox rm and gain more features.
    unixtools.procps  # Avoid busybox ps and watch.

    nano
    ed
    vim
    mg
    emacs
    ispell  # Emacs needs this for flyspell.

    git

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

    nixos-option
    nix-index

    hw-probe
  ];
}
