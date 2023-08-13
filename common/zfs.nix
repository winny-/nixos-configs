{ config, pkgs, lib, options, inputs, ... }:
{
  options = with lib; with types; {
    my.zfs.enable = mkEnableOption {
      default = config.boot.zfs.enabled;
      description = ''
        Enable zfs services such as auto-scrub, periodic trim, and snapshots.
      '';
    };
  };
  config = with lib; let
    cfg = config.my.zfs;
  in
    {
      services.zfs.autoSnapshot.enable = cfg.enable;
      services.zfs.trim.enable = cfg.enable;
      services.zfs.autoScrub.enable = cfg.enable;
      boot.supportedFilesystems = if cfg.enable then [ "zfs" ] else [];
      boot.plymouth.enable = mkForce false;
    };
}
