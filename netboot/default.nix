let
  bootSystem = import <nixpkgs/nixos> {
    # system = ...;

    configuration = { config, pkgs, lib, ... }: with lib; {
      imports = [
        <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
      ];
      ## Some useful options for setting up a new system
      services.getty.autologinUser = mkForce "root";
      # users.users.root.openssh.authorizedKeys.keys = [ ... ];
      # console.keyMap = "de";
    };
  };

  pkgs = import <nixpkgs> {};
in
pkgs.symlinkJoin {
  name = "netboot";
  paths = with bootSystem.config.system.build; [
    netbootRamdisk
    kernel
    netbootIpxeScript
  ];
  preferLocalBuild = true;
}
