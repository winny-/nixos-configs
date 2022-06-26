{ pkgs, ... }:
{
  programs.mosh.enable = true;
  environment.systemPackages = [ pkgs.mosh ];
}
