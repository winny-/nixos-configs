{ ... }:
{
  services.syncthing = {
    enable = true;
    user = "winston";
    dataDir = "/home/winston/sync";    # Default folder for new synced folders
    configDir = "/home/winston/.config/syncthing";   # Folder for Syncthing's settings and keys
  };
}
