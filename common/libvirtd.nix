{ config, pkgs, lib, ... }:
with lib; {
  options = {
    my.libvirtd.interfaces.primary = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = ''
        Primary network for libvirtd bridging.
      '';
    };
  };
  config = {
    users.users.winston.extraGroups = [ "libvirtd" ];
    virtualisation.libvirtd.enable = true;
    security.polkit.enable = true;  # Required by libvirtd.
    networking.bridges = mkMerge [      {
        libvirtdint0.interfaces = [];
        libvirtdint1.interfaces = [];
        libvirtdint2.interfaces = [];

      }
      (mkIf (config.my.libvirtd.interfaces.primary != null) {
        libvirtdeth0.interfaces = [ config.my.libvirtd.interfaces.primary ];
      })];

    # You'll also need to add something like the following to your domain's XML
    # as a child element of the <filesystem> element:
    #
    # <binary path='/run/current-system/sw/bin/virtiofsd' xattr='on'></binary>
    #
    environment.systemPackages = with pkgs; [
      virtiofsd
    ];

    # Direct users to the system local instance instead of the user session
    # instance.  (It is generally not productive to use a session instance due to
    # limited permissions and possible network configurations.)
    environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
  };
}
