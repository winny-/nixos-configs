# See
#
# https://stackoverflow.com/questions/36000514/how-to-override-2-two-packages-in-nixos-configuration-nix
# https://nixos.org/manual/nixpkgs/stable/#sec-modify-via-packageOverrides
# https://www.reddit.com/r/NixOS/comments/78q3a5/how_to_build_own_nixos_installable_package/

{ pkgs, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: rec {
    hw-probe = pkgs.callPackage ./hw-probe.nix {};
    nut = pkgs.callPackage ./nut {};
    droid-fonts = pkgs.callPackage ./droid-fonts {};
  };
}
