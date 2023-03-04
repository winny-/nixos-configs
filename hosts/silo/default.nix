{ config, pkgs, ... }:
{
  imports = [
    ./grafana.nix
    ./shares.nix
    ./hardware-configuration.nix
    ../../common/docker.nix
    ../../common/libvirtd.nix
    ../../common/netdata.nix
    ../../common/borgmatic.nix
    ../../common/base.nix
  ];

  users.motd = ''

                               +&-
         Welcome to           _.-^-._    .--.
            silo.          .-'   _   '-. |__|
                          /     |_|     \|  |
                         /               \  |
                        /|     _____     |\ |
                         |    |==|==|    |  |
     |---|---|---|---|---|    |--|--|    |  |
     |---|---|---|---|---|    |==|==|    |  |
    ^jgs^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  '';

  my.borgmatic = {
    enable = true;
    hostname = "pcm86lii.repo.borgbase.com";
    username = "pcm86lii";
    directories = [
      "/var/lib/nextcloud"
      "/var/lib/jellyfin"
      "/home"
      "/root"
      "/secrets"
    ];
    excludes = [
      ".cache/*"
      "/var/lib/jellyfin/transcodes/*"
    ];
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    device = "/dev/disk/by-id/ata-CT120BX500SSD1_1943E3D1AC45";
    mirroredBoots = [
      {
        path = "/boot2";
        devices = ["/dev/disk/by-id/ata-CT120BX500SSD1_1943E3D1AC4B"];
      }
    ];
  };

  boot.kernelParams = [
    "console=ttyS0,115200"
    "console=ttyS1,115200"
    "console=ttyS2,115200"
    "console=ttyS3,115200"
    "console=tty1"
  ];

  # ssh -p 2222 root@slio
  # ~ # zfs load-key -a
  # Enter passphrase for 'rpool':
  # 1 / 1 key(s) successfully loaded
  # ~ # pkill zfs
  # (You'll lose access to the server at this time because the sshd stops and
  # boot continues.)

  boot.initrd = {
    availableKernelModules = ["igb" "e1000e"];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [/secrets/initrd/ssh_host_rsa_key /secrets/initrd/ssh_host_ed25519_key];
        authorizedKeys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+J0puhRQksmrEQgL6pkb4DW/q5eap2sY6GKMegPb6Jy644yBO8ADsTctNG8Rt4uJE62Uct1f2WXAn4dzRDMhSgvQO0qJ9LO4TxLiyAQe0Wiq7R6joORH0ZfpN222epaK2ZhxKj2UCE2n3Xr6wxmYDH3RoE2whL8QtsBp4QHe9vPbiszm2vMNVIQ3YteJ8NVNX9DGEAiBoX89jUT8Gw9IBTmNDaI1Rw/w9S9JGczBF8vfzB2zCCMQWhk/oTB7hVH/Y9uG+M8rq8X1vsxqGaeonvTZUzjeLCQPYDx0MHLTmVtY8DmaL/9aXTrYiVIxffiedWimQqL14OdygQOkYfY2X winston@winston-one"];
      };
    };
  };

  services.openssh.ports = [ 22 9998 ];

  networking.hostName = "silo";
  networking.hostId = "9ea35398";
  networking.interfaces.eno1.useDHCP = true;

  fileSystems."/multimedia" = {
    device = "naspool/multimedia";
    fsType = "zfs";
  };
  fileSystems."/multimedia/video" = {
    device = "naspool/multimedia/video";
    fsType = "zfs";
  };
  fileSystems."/multimedia/music" = {
    device = "naspool/multimedia/music";
    fsType = "zfs";
  };
  fileSystems."/var/lib/nextcloud" = {
    device = "naspool/data/nextcloud";
    fsType = "zfs";
  };
  services.nextcloud = {
    enable = true;
    hostName = "nc.winny.tech";
    https = true;
    package = pkgs.nextcloud25;
    config.adminpassFile = "/secrets/nextcloud/adminpass";
    enableBrokenCiphersForSSE = false;

    # Setup tuning recommendations from nc admin dashboard.
    phpOptions."opcache.interned_strings_buffer" = "16";
    config.defaultPhoneRegion = "US";
  };
  # TODO migrate nextcloud sqlite to mysql.
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  services.jellyfin.enable = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@winny.tech";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    virtualHosts = {
      "jellyfin.winny.tech" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/empty";
        locations."/" = {
          proxyPass = "http://localhost:8096/";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
          '';
        };
      };
      "netdata.silo.home.winny.tech" = {
        serverAliases = [ "netdata.silo" ];
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://localhost:19999/";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
          '';
        };
      };
      "nc.winny.tech" = {
        forceSSL = true;
        enableACME = true;
      };
      "silo.winny.tech" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/srv/www/silo.winny.tech/";
        };
        locations."/transmission/" = {
          root = "/var/empty";

          # This is "secure" because I don't mirror the built derivations
          # anywhere or allow other users to log into this server.  The
          # password should be world readable so I wouldn't depend on this for
          # anything too serious.
          basicAuth.transmission = builtins.readFile "/secrets/transmission/basic_auth";
          proxyPass = "http://192.168.122.192:9091/transmission/";

          recommendedProxySettings = true;
          proxyWebsockets = true;
          extraConfig = ''
            proxy_pass_request_headers on;
          '';
        };
      };
    };
  };


  system.stateVersion = "22.05";
}
