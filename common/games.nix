{ pkgs, inputs, ... }:
{
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.dgltool.packages.x86_64-linux.dgltool
    steam
    xonotic
    gzdoom
    inputs.jhmod.packages.x86_64-linux.jhmod
  ];
}
