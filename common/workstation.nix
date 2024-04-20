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
    ./netdata.nix
    ./sanity.nix
  ];

  fileSystems."/backup" = {
    device = "/dev/disk/by-uuid/fb07e0e8-4cf1-4a53-a5ed-2330c6602525";
    fsType = "ext4";
    options = [ "noauto" ];
  };

  fileSystems."/mnt/multimedia" = {
    device = "//silo.home.winny.tech/multimedia";
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

  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager = {
      defaultSession = mkForce "plasmawayland";
      sddm.enable = true;
      startx.enable = true;
      # autoLogin.user = "winston";
    };
    desktopManager = {
      gnome.enable = mkDefault false;
      pantheon.enable = mkDefault false;
      xfce.enable = mkDefault false;
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

  programs.sway.enable = true;

  services.ddccontrol.enable = true;

  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };
  boot.plymouth.enable = true;

  # Skrooge and others are not packaged in nixpkgs.  Let's get cracking with
  # using these tools.  Package later.
  services.flatpak.enable = true;

  programs.dconf.enable = true;  # GNU Cash is fun to watch break in new and
                                 # unique ways when dcond isn't available,
                                 # without informing the user about it.

  # Theming
  qt.platformTheme = mkDefault "gtk";
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
  users.users.winston.extraGroups = [ "video" ];

  # https://nixos.wiki/wiki/Firefox#Tips_2 (touchscreen support)
  environment.sessionVariables.MOZ_USE_XINPUT2 = "1";

  my.emacs-package = with pkgs; ((emacsPackagesFor emacs29-pgtk).emacsWithPackages (
      epkgs: [ epkgs.vterm ]
    ));

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    jetbrains.idea-community
    xournalpp

    gnucash

    tor-browser-bundle-bin
    firefox

    # Correspondence
    thunderbird
    signal-desktop
    weechat
    (pkgs.mumble.override { pulseSupport = true; })  # See https://nixos.wiki/wiki/Mumble

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
    krita

    openvpn

    pavucontrol
    obs-studio
    audacity
    kdenlive
    kazam
    ffmpeg
    (mpv.override { scripts = with mpvScripts; [ mpris ]; })
    playerctl
    mediainfo
    zathura
    glxinfo
    theme-vertex
    gnome.adwaita-icon-theme  # Cursor
    libnotify  # notify-send
    pass
    acpilight
    zeal
    xdragon  # Drag n drop
    v4l-utils
    emote  # Emoji selector

    # Coding stuff
    dbeaver
    racket
    hadolint
    python3
    virtualenv
    postgresql
    heroku
    flyctl
    nodejs

    glab
    gh

    virt-manager

    # Utilities
    gparted

    # Backup
    borgmatic
    borgbackup

    # Remote login
    remmina
    unison

    unrar
    unzip
    koreader

    wl-clipboard
    alacritty
    tessen  # rofi-pass replacement that works on wayland and X11.
    nextcloud-client
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
