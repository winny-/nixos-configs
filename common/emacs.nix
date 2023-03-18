{ pkgs, lib, options, ... }:
{
  options = with lib; with types; {
    my.emacs-package = mkOption {
      default = pkgs.emacs-nox;
      defaultText = "pkgs.emacs-nox";
      type = package;
      description = ''
        Emacs package to be installed.
      '';
    };
  };
}
