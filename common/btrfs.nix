{ config, pkgs, lib, options, inputs, ... }:
{
  options = with lib; with types; {
    my.btrfs.enable = mkOption {
      default = false;
      type = bool;
      description = ''
        Enable btrfs services such as auto-scrub.
      '';
    };
  };
  config = with lib; let
    cfg = config.my.btrfs;
  in {
    services.btrfs.autoScrub.enable = cfg.enable;
    services.btrfs.autoScrub.interval = "weekly";
    environment.systemPackages = [ pkgs.compsize ];
  };
}
