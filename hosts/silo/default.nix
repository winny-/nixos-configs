{ config, pkgs, unstable, ... }:
{
  imports = [
    ./grafana.nix
    ./shares.nix
    ./hardware-configuration.nix
    ../../common/docker.nix
    ../../common/libvirtd.nix
    ../../common/netdata.nix
    ../../common/borgmatic.nix
    ../../common/syncthing.nix
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

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  # services.openssh.extraConfig = ''
  #   Match User backup-toybox
  #     ChrootDirectory /backup/toybox
  #     ForceCommand internal-sftp
  #     AllowTcpForwarding no
  # '';

  users.users.backup-toybox = {
    isNormalUser = true;
    home = "/backup/toybox";
    group = "backup-toybox";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCl+ygtq5VGhKoyGwjbzHQlGsA1G8Icnl0RgLH2Hypq toybox backup"
    ];
    shell = pkgs.bashInteractive;
  };
  users.groups.backup-toybox = {};

  my.borgmatic = {
    enable = true;
    hostname = "pcm86lii.repo.borgbase.com";
    username = "pcm86lii";
    directories = [
      config.services.mysqlBackup.location
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
  networking.domain = "winny.tech";
  networking.hostId = "9ea35398";
  networking.interfaces.eno1.useDHCP = true;

  my.zfs.enable = true;
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
  fileSystems."/backup" = {
    device = "naspool/backup";
    fsType = "zfs";
  };
  fileSystems."/backup/bulk" = {
    device = "naspool/backup/bulk";
    fsType = "zfs";
  };
  fileSystems."/backup/toybox" = {
    device = "naspool/backup/toybox";
    fsType = "zfs";
  };
  systemd.services.backup = {
    requires = ["mysql-backup.service"];
    after = ["mysql-backup.service"];
  };
  services.mysqlBackup = {
    enable = true;
    databases = [
      config.services.nextcloud.config.dbname
    ];
  };
  systemd.services."nextcloud-setup" = let
    deps = [
      "mysql.service"
      "memcached.service"
      "redis-nextcloud.service"
    ];
  in {
    requires = deps;
    after = deps;
  };
  services.memcached.enable = true;
  services.redis.servers.nextcloud = {
    enable = true;
    user = "nextcloud";
    port = 0;
  };
  # Note to self: Set up a prometheus exporter for php-fpm.  Then use those
  # metrics to guide any performance tuning.
  services.nextcloud = {
    enable = true;
    hostName = "nc.winny.tech";
    https = true;
    package = pkgs.nextcloud27;
    caching = {
      redis = true;
      apcu = true;
      memcached = true;
    };
    config = {
      adminpassFile = "/secrets/nextcloud/adminpass";
      dbtype = "mysql";
      dbuser = "nextcloud";
      dbname = "nextcloud";
    };
    extraOptions = {
      "mysql.utf8mb4" = true;
      redis = {
        host = config.services.redis.servers.nextcloud.unixSocket;
        port = 0;
        dbindex = 0;
        timeout = 1.5;
      };
      "memcache.local" = "\\OC\\Memcache\\APCu";
      "memcache.distributed" = "\\OC\\Memcache\\Redis";
      "memcache.locking" = "\\OC\\Memcache\\Redis";
    };

    # Setup tuning recommendations from nc admin dashboard.
    phpOptions."opcache.interned_strings_buffer" = "16";
    config.defaultPhoneRegion = "US";
  };
  # In order to migrate to mysql you first have to (based off of https://docs.nextcloud.com/server/25/admin_manual/configuration_database/db_conversion.html :
  # 1) Set up *just* the mysql cfg below then nixos-rebuild switch
  # 2) sudo -u nextcloud nextcloud-occ db:convert-type -n --all-apps mysql nextcloud localhost nextcloud
  # 3) Configure the "db" entries in the above services.nextcloud.config
  # 4) switch again
  # 5) in the case it complain about 4 byte characters, you may need to refer to https://docs.nextcloud.com/server/latest/admin_manual/configuration_database/mysql_4byte_support.html
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      { name = "nextcloud";
        ensurePermissions."nextcloud.*" = "ALL PRIVILEGES"; }
    ];
    settings = {
      mysqld = {
        innodb_file_per_table = 1;
      };
    };
  };

  hardware.opengl.enable = true;
  services.jellyfin = {
    enable = true;
    package = unstable.jellyfin;
  };
  users.users.jellyfin.extraGroups = [ "video" ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@winny.tech";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.gotify = {
    enable = true;
    port = 60717;
  };
  services.searx = {
    enable = true;
    settings.server = {
      secret_key = builtins.readFile "/secrets/searx/secret_key";
      bind_address = "127.0.0.1";
      port = 3050;
    };
  };
  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      error_log syslog:server=unix:/dev/log;
      access_log syslog:server=unix:/dev/log;
    '';
    virtualHosts = let
      siloWithSSL = useSSL: {
        forceSSL = useSSL;
        enableACME = useSSL;
        locations."/" = {
          root = "/srv/www/silo.winny.tech/";
        };
        locations."/transmission/" = {
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
      proxyPass = url: {
          recommendedProxySettings = true;
          proxyPass = url;
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
          '';
      };
    in {
      "default" =  {
        default = true;
        extraConfig = ''
          return 302 https://silo.winny.tech/;
        '';
      };
      "searx.winny.tech" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = proxyPass "http://localhost:${toString config.services.searx.settings.server.port}";
        basicAuth.searx = builtins.readFile "/secrets/searx/basic_auth";
      };
      "jellyfin.winny.tech" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = proxyPass "http://localhost:8096/";
      };
      "netdata.silo.home.winny.tech" = {
        serverAliases = [ "netdata.silo" ];
        locations."/" = proxyPass "http://localhost:19999/";
      };
      "nc.winny.tech" = {
        forceSSL = true;
        enableACME = true;
      };
      "silo.winny.tech" = siloWithSSL true;
      "silo.home.winny.tech" = siloWithSSL false;
      "gotify.winny.tech" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = proxyPass "http://localhost:60717/";
      };
    };
  };

  system.stateVersion = "22.05";
}
