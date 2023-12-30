{ config, pkgs, lib, options, inputs, ... }:
with lib; {
  imports = [
    ../package-overrides
    ./mosh.nix
    ./tmp-as-tmpfs.nix
    ./bare-metal.nix
    ./zfs.nix
    ./btrfs.nix
    ./emacs.nix
  ];

  zramSwap = {
    enable = mkDefault true;
    memoryPercent = mkDefault 20;
    algorithm = mkDefault "lz4";
  };

  hardware.enableAllFirmware = true;
  services.earlyoom.enable = mkDefault true;

  time.timeZone = mkDefault "America/Chicago";

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    randomizedDelaySec = "45min";
    dates = "monthly";
    options = "--delete-older-than 30d";
  };

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
    pinentryFlavor = "gtk2";
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
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

  environment.homeBinInPath = true;

  environment.variables = {
    # NixOS defaults to using your XDG_RUNTIME_DIR created by your
    # systemd-logind session.  This is typically a tmpdir that grows to 10% of
    # your RAM.
    #
    # This is not suitable as a temporary directory because tools such as
    # nix-build will download large files to this tmpdir.  Prefer /tmp because
    # the sysop can set up a large shared tmpfs or just use a filesystem on
    # disk.  See also `tmp-as-tmpfs.nix` in this directory.
    TMPDIR = "/tmp";
  };

  environment.systemPackages = with pkgs; [
    tmux
    picocom

    # Replace busybox stuff.
    coreutils  # Avoid busybox rm and gain more features.
    ps
    watch
    sysctl
    usbutils  # Avoid busybox lsusb
    util-linux
    bc
    unzip

    fzf

    nano
    ed
    vim
    config.my.emacs-package
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    ispell  # Emacs needs this for flyspell.

    sqlite-interactive

    # https://github.com/NixOS/nixpkgs/issues/173707 pygrep support
    (python3.withPackages (_: [ pre-commit ]))

    git
    git-ignore
    git-lfs
    git-crypt

    jq
    yq

    lynx
    links2

    shellcheck
    licensor

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
    iotop

    powertop

    ncdu
    htop
    glances
    mc
    nwipe
    ddrescue
    cryptsetup  # Sometimes I manually mount stuff so ensure cryptsetup is
                # always available
    gotify-cli
    gnupg
    acpi
    sysstat
    dstat
    stress-ng
    fio
    nmap
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

    # Network utilities and diagnostics
    inetutils
    mtr
    iperf
    binwalk
    openssl
    speedtest-cli
    httpie
    wget
    tcpdump
    bind
    bridge-utils
    ethtool
    wgetpaste
    socat
    busybox  # For httpd.
    wol
    squashfsTools

    # Software diagnostics
    gdb
    ltrace
    strace
    config.boot.kernelPackages.perf
  ];
}
