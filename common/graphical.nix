# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./base.nix
      ./fonts.nix
      ./docker.nix
      ./libvirtd.nix
      ./android.nix
      ./games.nix
    ];

  services.xserver = {
    enable = true;
    displayManager = {
      defaultSession = "xfce";
      lightdm.enable = true;
      startx.enable = true;
      autoLogin.user = "winston";
    };
    desktopManager = {
      gnome.enable = false;
      pantheon.enable = false;
      xfce.enable = true;
    };
    layout = "us";
    xkbVariant = "dvorak";
    extraConfig =
      ''
        Section "InputClass"
                Identifier  "Marble Mouse"
                MatchProduct "Logitech USB Trackball"
                MatchIsPointer "on"
                MatchDevicePath "/dev/input/event*"
                Driver "evdev"

        #       Physical button #s:     A b D - - - - B C
        #       Option "ButtonMapping" "1 8 3 4 5 6 7 2 2"   right-hand placement
        #       Option "ButtonMapping" "3 8 1 4 5 6 7 2 2"   left-hand placement
        #       b = A & D
                Option "ButtonMapping" "1 8 3 4 5 6 7 2 2"

        #       EmulateWheel: Use Marble Mouse trackball as mouse wheel
        #       Factory Default: 8; Use 9 for right side small button
                Option "EmulateWheel" "true"
                Option "EmulateWheelButton" "8"

        #       EmulateWheelInertia: How far (in pixels) the pointer must move to
        #       generate button press/release events in wheel emulation mode.
        #       Factory Default: 50
                Option "EmulateWheelInertia" "10"

        #       Axis Mapping: Enable vertical [ZAxis] and horizontal [XAxis] scrolling
                Option "ZAxisMapping" "4 5"
                Option "XAxisMapping" "6 7"

        #       Emulate3Buttons: Required to interpret simultaneous press of two large
        #       buttons, A & D, as a seperate command, b.
        #       Factory Default: true
                Option "Emulate3Buttons" "false"
        EndSection
        Section "InputClass"
          Identifier      "yubikey"
          MatchIsKeyboard "on"
          MatchVendor     "Yubico"
          #MatchProduct    "Yubico Yubikey II"
          Driver          "evdev"
          Option          "XkbRules" "evdev"
          Option          "XkbModel" "pc105"
          Option          "XkbLayout" "us"
          Option          "XkbVariant" "basic"
        EndSection
      '';
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    gutenprintBin
    postscript-lexmark
  ];

  services.ddccontrol.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraConfig = ''

    ################################################################
    # from graphical.nix
    ################################################################

    # Disable annoying audio click in/out when playback is paused temporarily.
    unload-module module-suspend-on-idle
  '';
  hardware.bluetooth.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  users.users.winston.extraGroups = [ "wireshark" ];
  programs.wireshark.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libvterm  # Emacs vterm terminal emulator is $$$.
    cmake  # vterm needs this to compile.
    gnumake  # cmake needs it.  Not sure why this isn't pulled in already.
    gcc  # Need a compiler too.
    git
    git-crypt

    # HTTP clients
    qutebrowser
    tor-browser-bundle-bin
    firefox

    sacc

    jq
    yq

    # Correspondence
    thunderbird
    neomutt
    signal-desktop
    weechat
    (pkgs.mumble.override { pulseSupport = true; })  # See https://nixos.wiki/wiki/Mumble

    # PIM
    vdirsyncer
    khal
    khard

    # Publishing/document preparation
    libreoffice-fresh
    # Depends on a vulnerable version of Python Pillow so skip for now.
    #scribus
    hugo
    postcss-cli
    img2pdf
    texlive.combined.scheme-full

    qrencode

    # Image editing
    inkscape
    gimp

    openvpn

    deadbeef-with-plugins
    pavucontrol
    obs-studio
    kdenlive
    kazam
    ffmpeg
    mpv
    zathura
    i3
    i3status
    i3lock
    urlview
    xdotool
    xsel
    xclip
    glxinfo
    xorg.listres
    xorg.xeyes
    xorg.xclock
    xfce.xfce4-terminal
    xfce.xfce4-whiskermenu-plugin
    libnotify  # notify-send
    rofi
    xbindkeys
    dunst
    pass
    rofi-pass
    redshift
    ponymix
    mpvc
    maim
    slop
    arandr
    wmctrl
    picom
    wmname
    xbanish
    xkbset
    acpilight
    zeal
    ledger
    xournal
    v4l-utils
    emote  # Emoji selector

    # Coding stuff
    racket
    python
    virtualenv
    postgresql
    pre-commit
    heroku
    nodejs
    ghc
    ocaml
    sbcl

    glab
    gh
    pre-commit

    virt-manager

    # Network utilities and diagnostics
    inetutils
    mtr
    iperf
    wireshark
    openssl
    speedtest-cli
    httpie
    wget
    tcpdump
    bind
    bridge-utils
    ethtool
    mosh
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

    # Utilities
    gparted
    latencytop

    # Backup
    borgmatic
    borgbackup

    # Remote login
    drawterm
    remmina
    unison
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
