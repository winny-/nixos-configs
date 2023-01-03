{ ... }:
{
  services.samba-wsdd.enable = true;
  networking.firewall.allowedTCPPorts = [ 5357 ];
  networking.firewall.allowedUDPPorts = [ 3702 ];
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = Silo
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      multimedia = {
        path = "/multimedia";
        browseable = "yes";
	"read only" = "yes";
	"guest ok" = "yes";
      };
    };
  };
}
