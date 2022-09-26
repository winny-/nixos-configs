{ pkgs, inputs, ... }:
{
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    steam
    xonotic
    gzdoom
    inputs.jhmod.packages.x86_64-linux.jhmod
  ];
}
