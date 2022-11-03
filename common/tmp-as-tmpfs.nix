{ config, pkgs, lib, options, inputs, ... }:
with lib; {
    options = {
    my.tmp-as-tmpfs.enable = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Use a in-memory filesystem for /tmp.  Defaults to false.
      '';
    };
    my.tmp-as-tmpfs.size = mkOption {
      default = "4G";
      type = types.str;
      description = ''
        /tmp as tmpfs size.  Defaults to 4G.
      '';
    };
  };

  config = mkIf config.my.tmp-as-tmpfs.enable {
    fileSystems."/tmp" = {
      fsType = "tmpfs";
      options = [
        "noatime"
        "mode=1777"
        "size=${config.my.tmp-as-tmpfs.size}"
      ];
    };
  };
}
