{ ... }:
{
  xdg.mime.defaultApplications =
    let browser = "org.qutebrowser.qutebrowser.desktop";
        documentViewer = "org.pwmt.zathura.desktop";
        imageViewer = "org.xfce.ristretto.desktop";
    in {
      "application/pdf" = documentViewer;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "text/html" = browser;
      "image/jpeg" = imageViewer;
      "image/png" = imageViewer;
      "image/gif" = imageViewer;
    };
}
