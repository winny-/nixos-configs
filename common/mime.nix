{ ... }:
{
  # Tell xdg-open to chill and just use the following default applications.
  # Without this setting, xdg-open will try to defer to exo-open despite not
  # using XFCE.  exo-open will use whatever XFCE4 defaults you may have left
  # over in your homedir.  Cursed.
  environment.sessionVariables.XDG_CURRENT_DESKTOP = "X-Generic";

  xdg.mime.defaultApplications =
    let browser = "firefox.desktop";
        documentViewer = "org.pwmt.zathura.desktop";
        imageViewer = "org.xfce.ristretto.desktop";
        emailClient = "thunderbird.desktop";
    in {
      "application/pdf" = documentViewer;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/mailto" = emailClient;
      "message/rfc822" = emailClient;
      "text/calendar" = emailClient;
      "text/x-vcard" = emailClient;
      "text/html" = browser;
      "image/jpeg" = imageViewer;
      "image/png" = imageViewer;
      "image/gif" = imageViewer;
    };
}
