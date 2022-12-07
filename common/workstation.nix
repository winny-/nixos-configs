{ config, pkgs, lib, ... }:
with lib;
{
  imports = [
    ./base.nix
    ./bare-metal.nix
    ./fonts.nix
    ./docker.nix
    ./libvirtd.nix
    ./android.nix
    ./games.nix
    ./printing.nix
    ./wireshark.nix
    ./syncthing.nix
    ./cdrecord.nix
    ./mime.nix
    ./portal
    ./vaapi.nix
  ];

  fileSystems."/backup" = {
    device = "/dev/disk/by-uuid/fb07e0e8-4cf1-4a53-a5ed-2330c6602525";
    fsType = "ext4";
    options = [ "noauto" ];
  };

  fileSystems."/mnt/multimedia" = {
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

  services.netdata = {
    enable = true;
    python.enable = true;
  };

  services.xserver = {
    enable = true;
    displayManager = {
      defaultSession = mkDefault "xfce";
      lightdm.enable = true;
      startx.enable = true;
      autoLogin.user = "winston";
    };
    desktopManager = {
      gnome.enable = mkDefault false;
      pantheon.enable = mkDefault false;
      xfce.enable = mkDefault true;
    };
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "ctrl:swapcaps";

    libinput = {
      enable = true;
      mouse.tapping = false;
      touchpad.clickMethod = "clickfinger";
    };

    synaptics.tapButtons = mkDefault false;

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

  services.ddccontrol.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.bluetooth.enable = true;

  # Theming
  qt5.platformTheme = mkDefault "gtk";
  environment.etc."xdg/gtk-2.0/gtkrc".text = ''
    gtk-theme-name="Vertex-Dark"
    gtk-icon-theme-name="HighContrast"
  '';
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=High Contrast
    gtk-theme-name=Vertex-Dark
    gtk-cursor-theme-name=Adwaita
  '';

  programs.light.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  # https://nixos.wiki/wiki/Firefox#Tips_2 (touchscreen support)
  environment.sessionVariables.MOZ_USE_XINPUT2 = "1";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (emacsWithPackages
      (with emacsPackages;
        [ vterm ]))
    sqlite-interactive

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
    zbar  # use zbarimg to parse qr codes from pictures

    # Image editing
    inkscape
    gimp
    imagemagick

    openvpn

    deadbeef-with-plugins
    pavucontrol
    obs-studio
    kdenlive
    kazam
    ffmpeg
    ffcast  # rofi-screenshot
    xorg.xwininfo # rofi-screenshot
    (mpv.override { scripts = with mpvScripts; [ mpris ]; })
    playerctl
    mediainfo
    zathura
    awesome
    i3
    i3status
    i3lock
    urlview
    xdotool
    xsel
    xclip
    glxinfo
    xorg.xkill
    xorg.xdpyinfo
    xorg.listres
    xorg.xeyes
    xorg.xclock
    xfce.xfce4-terminal
    xfce.xfce4-whiskermenu-plugin
    theme-vertex
    gnome.adwaita-icon-theme  # Cursor
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
    dbeaver
    racket
    python3
    virtualenv
    postgresql
    pre-commit
    heroku
    flyctl
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
    ghidra
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

    unrar
    unzip
    koreader
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
