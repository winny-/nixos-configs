{ pkgs, lib, options, config, ... }:
{
  options = with lib; with types; {
    my.borgmatic.enable = mkOption {
      default = false;
      type = bool;
      description = ''
        Enable borgmatic/borgbase support.
      '';
    };
    my.borgmatic.hostname = mkOption {
      default = null;
      type = nullOr str;
      description = ''
        Hostname for borgbase repository.
      '';
    };
    my.borgmatic.username = mkOption {
      default = null;
      type = nullOr str;
      description = ''
        Username for borgbase repository.
      '';
    };
    my.borgmatic.retention.days = mkOption {
      default = 7;
      type = number;
      description = ''
        How many days to keep the 1st-tiered/"child" backups.
      '';
    };
    my.borgmatic.retention.weeks = mkOption {
      default = 4;
      type = number;
      description = ''
        How many weeks to keep the 2nd-tiered/"father" backups.
      '';
    };
    my.borgmatic.retention.months = mkOption {
      default = 3;
      type = number;
      description = ''
        How many days to keep the 3rd-tiered/"grandfather" backups.
      '';
    };
    my.borgmatic.directories = mkOption {
      default = ["/home" "/root"];
      type = listOf str;
      description = ''
        Which directories to back up.
      '';
    };
    my.borgmatic.exclude = mkOption {
      default = [];
      type = listOf str;
      description = ''
        Glob patterns to exclude from backup.
      '';
    };
  };

  config = with lib; let
    cfg = config.my.borgmatic;
    # N.B. this should generate valid YAML because YAML is 99.999% a superset of JSON.
    source_directories = concatStringsSep ", " (map builtins.toJSON cfg.directories);
    exclude_patterns = concatStringsSep ", " (map builtins.toJSON cfg.exclude);
  in {
    systemd.services."generate-borgmatic-secrets" = {
      enable = cfg.enable;
      description = "Generate secrets used by borgmatic";
      serviceConfig = {
        Type = "oneshot";
        UMask = 0077;
      };
      script = ''
        mkdir -p /secrets/borgmatic/borgbase
        if [[ ! -f /secrets/borgmatic/borgbase/ssh ]]; then
          ssh-keygen -t ed25519 -q -f /secrets/borgmatic/borgbase/ssh
        fi
        if [[ ! -f /secrets/borgmatic/borgbase/passphrase ]]; then
          { tr -dc A-Za-z0-9 </dev/urandom | head -c 80; echo; } > \
            /secrets/borgmatic/borgbase/passphrase
        fi
      '';
      path = [ pkgs.openssh ];
      wantedBy = [
        "multi-user.target"
        "backup.service"
      ];
    };

    systemd.services.backup = {
      enable = cfg.enable;
      serviceConfig.Type = "oneshot";
      unitConfig.Wants = [ "network-online.target" ];
      path = [ pkgs.borgmatic ];
      script = ''
        borgmatic -c /etc/borgmatic/borgbase.yaml \
          --syslog-verbosity -1 \
          --verbosity 1
      '';
    };

    systemd.timers.daily-backup = {
      enable = cfg.enable;
      timerConfig = {
        Unit = "backup.service";
        OnCalendar = [ "*-*-* 04:00:00" ];
        OnActiveSec=600;
      };
      wantedBy = [ "timers.target" ];
    };

    environment.etc."borgmatic/borgbase.yaml".text = ''
      location:
        source_directories: [${source_directories}]
        exclude_patterns: [${exclude_patterns}]
        repositories:
          - ssh://${cfg.username}@${cfg.hostname}/./repo
        one_file_system: true
      retention:
        keep_daily: ${toString cfg.retention.days}
        keep_weekly: ${toString cfg.retention.weeks}
        keep_monthly: ${toString cfg.retention.months}
      consistency:
        checks:
          - repository
          - archives
      storage:
        # Custom SSH Key in the config tree
        ssh_command: ssh -o PasswordAuthentication=no -i /secrets/borgmatic/borgbase/ssh
        # Password is in the repokey file
        encryption_passcommand: cat /secrets/borgmatic/borgbase/passphrase
    '';

    # Kind of perplexed this is such an involved process to safely retrieve ssh
    # host keys.  Sure you can just "ssh yourhost", visually verify, then hit
    # yes, writing some random file.  Generally you never want this on a system
    # with a declarative configuration (i.e. any system with something like
    # ansible or nix).  OpenSSH has come a long way but sometimes I can't help
    # but wonder how big of a rock do they live under?
    #
    # 1. Refer to https://www.borgbase.com/setup see the ssh fingerprints
    # 2. ssh-keyscan yourhost.repo.borgbase.com > /tmp/scan 2> /dev/null
    # 3. ssh-keygen -l -f /tmp/scan
    # 4. Verify the fingerprints match
    # 5. Then copy-paste the text after the host name below for each key type.

    programs.ssh.knownHosts."borgbase/rsa" = {
      hostNames = [ cfg.hostname ];
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6r8zHXR11Xja/o7HLIlrfo1L9i6RR1NDJUQB93hsVcD0Vh+rZB2yqHPt3xpgEGbKfxBaELcENms/GB1QgBJXLBSNwk7+0xaGTTYJWasyy9KMP6W51KkM97pCy3INzdZBT5jpY5awbSuns6ekcl5UALGroAkXnDMzgWLE7DyAp1ZNdcRYGzT7lPFFxfyczDkTeNBoNwFdqheZLO+LcX80Ds4H2Maj/04lfzVXDWShdvEPH04pazzcxidUysqNOc5MNMCqTmzLw8aiUZuc4k7MubpQ/soRPSVOq6iPB+Aw47fBzzpB0/I5Z6cAANNY0pRYbjyFZHIPcMKYIZLgbcWuj";
    };
    programs.ssh.knownHosts."borgbase/ecdsa" = {
      hostNames = [ cfg.hostname ];
      publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHYDOAh9uJnuVsYEZHDORpMbLHPWUoNSFTA84/Q4U/d99rDp2LE4Kr+kHHpuR6IXOSpoiTAg500CX+Q6IWJybHE=";
    };
    programs.ssh.knownHosts."borgbase/ed25519" = {
      hostNames = [ cfg.hostname ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGU0mISTyHBw9tBs6SuhSq8tvNM8m9eifQxM+88TowPO";
    };
  };
}
