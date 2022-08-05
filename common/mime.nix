{ ... }:
{
  xdg.mime.defaultApplications =
    let browser = "org.qutebrowser.qutebrowser.desktop";
    in {
      "application/pdf" = "zathura.desktop";
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "text/html" = browser;
  };
}
