{ ... }:
{
  power.ups = {
    enable = true;
    ups.main = {
      driver = "usbhid-ups";
      port = "auto";
      description = "Cyberpower big boi";
      # directives = [ "vendorid = 0764" ];
    };
  };

  systemd.services.upsmon.preStart = "mkdir -p /var/lib/nut";

  # Tools look in /nix/store/...-nut-.../etc/nut otherwise :(.
  # Also looking in wrong state directory OOTB.
  environment.variables = {
    NUT_CONFPATH = "/etc/nut";
    NUT_STATEPATH = "/var/lib/nut/"; 
  };


  environment.etc = {
    "nut/upsd.users" = {
      source = /secrets/nut/upsd.users;
      mode = "0600";
    };
    "nut/upsd.conf".text = "";
    "nut/upsmon.conf" = {
      source = /secrets/nut/upsmon.conf;
      mode = "0600";
    };
  };

  services.udev.extraRules = ''
    # This file is generated and installed by the Network UPS Tools package.
    # It sets the correct device permissions for nut-ipmipsu driver.

    KERNEL=="ipmi*", MODE="664", GROUP="nogroup"
    # This file is generated and installed by the Network UPS Tools package.

    ACTION=="remove", GOTO="nut-usbups_rules_end"
    SUBSYSTEM=="usb_device", GOTO="nut-usbups_rules_real"
    SUBSYSTEM=="usb", GOTO="nut-usbups_rules_real"
    GOTO="nut-usbups_rules_end"

    LABEL="nut-usbups_rules_real"
    #  SNR-UPS-LID-XXXX UPSes  - nutdrv_qx
    ATTR{idVendor}=="0001", ATTR{idProduct}=="0000", MODE="664", GROUP="nogroup"

    # Hewlett Packard
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="0001", MODE="664", GROUP="nogroup"
    #  T500  - bcmxcp_usb
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1f01", MODE="664", GROUP="nogroup"
    #  T750  - bcmxcp_usb
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1f02", MODE="664", GROUP="nogroup"
    #  HP T750 INTL  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1f06", MODE="664", GROUP="nogroup"
    #  HP T1000 INTL  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1f08", MODE="664", GROUP="nogroup"
    #  HP T1500 INTL  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1f09", MODE="664", GROUP="nogroup"
    #  HP R/T 2200 INTL (like SMART2200RMXL2U)  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1f0a", MODE="664", GROUP="nogroup"
    #  HP R1500 G2 and G3 INTL  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1fe0", MODE="664", GROUP="nogroup"
    #  HP T750 G2  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1fe1", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1fe2", MODE="664", GROUP="nogroup"
    #  HP T1500 G3  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1fe3", MODE="664", GROUP="nogroup"
    #  R/T3000  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1fe5", MODE="664", GROUP="nogroup"
    #  R/T3000  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1fe6", MODE="664", GROUP="nogroup"
    #  various models  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1fe7", MODE="664", GROUP="nogroup"
    #  various models  - usbhid-ups
    ATTR{idVendor}=="03f0", ATTR{idProduct}=="1fe8", MODE="664", GROUP="nogroup"

    # Eaton
    #  various models  - usbhid-ups
    ATTR{idVendor}=="0463", ATTR{idProduct}=="0001", MODE="664", GROUP="nogroup"
    #  various models  - usbhid-ups
    ATTR{idVendor}=="0463", ATTR{idProduct}=="ffff", MODE="664", GROUP="nogroup"

    # Dell
    #  various models  - usbhid-ups
    ATTR{idVendor}=="047c", ATTR{idProduct}=="ffff", MODE="664", GROUP="nogroup"

    # ST Microelectronics
    #  TS Shara UPSes; vendor ID 0x0483 is from ST Microelectronics - with product IDs delegated to different OEMs  - nutdrv_qx
    ATTR{idVendor}=="0483", ATTR{idProduct}=="0035", MODE="664", GROUP="nogroup"
    #  USB IDs device table  - usbhid-ups
    ATTR{idVendor}=="0483", ATTR{idProduct}=="a113", MODE="664", GROUP="nogroup"

    # IBM
    #  6000 VA LCD 4U Rack UPS; 5396-1Kx  - usbhid-ups
    ATTR{idVendor}=="04b3", ATTR{idProduct}=="0001", MODE="664", GROUP="nogroup"

    # Riello (Cypress Semiconductor Corp.)
    #  various models  - riello_usb
    ATTR{idVendor}=="04b4", ATTR{idProduct}=="5500", MODE="664", GROUP="nogroup"

    # Minibox
    #  openUPS Intelligent UPS (minimum required firmware 1.4)  - usbhid-ups
    ATTR{idVendor}=="04d8", ATTR{idProduct}=="d004", MODE="664", GROUP="nogroup"
    #  openUPS Intelligent UPS (minimum required firmware 1.4)  - usbhid-ups
    ATTR{idVendor}=="04d8", ATTR{idProduct}=="d005", MODE="664", GROUP="nogroup"

    # Belkin
    #  F6H375-USB  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="0375", MODE="664", GROUP="nogroup"
    #  F6C550-AVR  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="0551", MODE="664", GROUP="nogroup"
    #  F6C1250-TW-RK  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="0750", MODE="664", GROUP="nogroup"
    #  F6C1500-TW-RK  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="0751", MODE="664", GROUP="nogroup"
    #  F6C900-UNV  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="0900", MODE="664", GROUP="nogroup"
    #  F6C100-UNV  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="0910", MODE="664", GROUP="nogroup"
    #  F6C120-UNV  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="0912", MODE="664", GROUP="nogroup"
    #  F6C800-UNV  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="0980", MODE="664", GROUP="nogroup"
    #  Regulator PRO-USB  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="0f51", MODE="664", GROUP="nogroup"
    #  F6C1100-UNV, F6C1200-UNV  - usbhid-ups
    ATTR{idVendor}=="050d", ATTR{idProduct}=="1100", MODE="664", GROUP="nogroup"

    # APC
    #  APC AP9584 Serial->USB kit  - usbhid-ups
    ATTR{idVendor}=="051d", ATTR{idProduct}=="0000", MODE="664", GROUP="nogroup"
    #  various models  - usbhid-ups
    ATTR{idVendor}=="051d", ATTR{idProduct}=="0002", MODE="664", GROUP="nogroup"
    #  various 5G models  - usbhid-ups
    ATTR{idVendor}=="051d", ATTR{idProduct}=="0003", MODE="664", GROUP="nogroup"

    # Powerware
    #  various models  - bcmxcp_usb
    ATTR{idVendor}=="0592", ATTR{idProduct}=="0002", MODE="664", GROUP="nogroup"
    #  PW 9140  - usbhid-ups
    ATTR{idVendor}=="0592", ATTR{idProduct}=="0004", MODE="664", GROUP="nogroup"
    #  Agiler UPS  - nutdrv_qx
    ATTR{idVendor}=="05b8", ATTR{idProduct}=="0000", MODE="664", GROUP="nogroup"

    # Delta UPS
    #  Delta UPS Amplon R Series, Single Phase UPS, 1/2/3 kVA  - usbhid-ups
    ATTR{idVendor}=="05dd", ATTR{idProduct}=="041b", MODE="664", GROUP="nogroup"
    #  Delta/Minuteman Enterprise Plus E1500RM2U  - usbhid-ups
    ATTR{idVendor}=="05dd", ATTR{idProduct}=="a011", MODE="664", GROUP="nogroup"
    #  Belkin F6C1200-UNV/Voltronic Power UPSes  - nutdrv_qx
    ATTR{idVendor}=="0665", ATTR{idProduct}=="5161", MODE="664", GROUP="nogroup"

    # Phoenixtec Power Co., Ltd
    #  Online Yunto YQ450  - nutdrv_qx
    ATTR{idVendor}=="06da", ATTR{idProduct}=="0002", MODE="664", GROUP="nogroup"
    #  Mustek Powermust  - nutdrv_qx
    ATTR{idVendor}=="06da", ATTR{idProduct}=="0003", MODE="664", GROUP="nogroup"
    #  Phoenixtec Innova 3/1 T  - nutdrv_qx
    ATTR{idVendor}=="06da", ATTR{idProduct}=="0004", MODE="664", GROUP="nogroup"
    #  Phoenixtec Innova RT  - nutdrv_qx
    ATTR{idVendor}=="06da", ATTR{idProduct}=="0005", MODE="664", GROUP="nogroup"
    #  Phoenixtec Innova T  - nutdrv_qx
    ATTR{idVendor}=="06da", ATTR{idProduct}=="0201", MODE="664", GROUP="nogroup"
    #  Online Zinto A  - nutdrv_qx
    ATTR{idVendor}=="06da", ATTR{idProduct}=="0601", MODE="664", GROUP="nogroup"
    #  PROTECT B / NAS  - usbhid-ups
    ATTR{idVendor}=="06da", ATTR{idProduct}=="ffff", MODE="664", GROUP="nogroup"

    # iDowell
    #  iDowell  - usbhid-ups
    ATTR{idVendor}=="075d", ATTR{idProduct}=="0300", MODE="664", GROUP="nogroup"

    # Cyber Power Systems
    #  900AVR/BC900D  - usbhid-ups
    ATTR{idVendor}=="0764", ATTR{idProduct}=="0005", MODE="664", GROUP="nogroup"
    #  Dynex DX-800U?, CP1200AVR/BC1200D, CP825AVR-G, CP1000AVRLCD, CP1000PFCLCD, CP1500C, CP550HG, etc.  - usbhid-ups
    ATTR{idVendor}=="0764", ATTR{idProduct}=="0501", MODE="664", GROUP="nogroup"
    #  OR2200LCDRM2U, OR700LCDRM1U, PR6000LCDRTXL5U  - usbhid-ups
    ATTR{idVendor}=="0764", ATTR{idProduct}=="0601", MODE="664", GROUP="nogroup"
    #  Sweex 1000VA  - richcomm_usb
    ATTR{idVendor}=="0925", ATTR{idProduct}=="1234", MODE="664", GROUP="nogroup"

    # TrippLite
    #  e.g. OMNIVS1000, SMART550USB, ...  - tripplite_usb
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="0001", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite AVR550U  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="1003", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite AVR750U  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="1007", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite ECO550UPS  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="1008", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite ECO550UPS  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="1009", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite ECO550UPS  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="1010", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite SU3000LCD2UHV  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="1330", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite OMNI1000LCD  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="2005", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite OMNI900LCD  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="2007", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="2008", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite Smart1000LCD  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="2009", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="2010", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="2011", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="2012", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="2013", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="2014", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3008", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3009", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3010", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3011", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite smart2200RMXL2U  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3012", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3013", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3014", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3015", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite Smart1500LCD (newer unit)  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3016", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite AVR750U (newer unit)  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="3024", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite SmartOnline SU1500RTXL2UA (older unit?)  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="4001", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite SmartOnline SU6000RT4U?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="4002", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite SmartOnline SU1500RTXL2ua  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="4003", MODE="664", GROUP="nogroup"
    #  e.g. TrippLite SmartOnline SU1000XLA  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="4004", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="4005", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="4006", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="4007", MODE="664", GROUP="nogroup"
    #  e.g. ?  - usbhid-ups
    ATTR{idVendor}=="09ae", ATTR{idProduct}=="4008", MODE="664", GROUP="nogroup"

    # PowerCOM
    #  PowerCOM Vanguard and BNT-xxxAP  - usbhid-ups
    ATTR{idVendor}=="0d9f", ATTR{idProduct}=="0001", MODE="664", GROUP="nogroup"
    #  PowerCOM Vanguard and BNT-xxxAP  - usbhid-ups
    ATTR{idVendor}=="0d9f", ATTR{idProduct}=="0004", MODE="664", GROUP="nogroup"
    #  PowerCOM IMP - IMPERIAL Series  - usbhid-ups
    ATTR{idVendor}=="0d9f", ATTR{idProduct}=="00a2", MODE="664", GROUP="nogroup"
    #  PowerCOM SKP - Smart KING Pro (all Smart series)  - usbhid-ups
    ATTR{idVendor}=="0d9f", ATTR{idProduct}=="00a3", MODE="664", GROUP="nogroup"
    #  PowerCOM WOW  - usbhid-ups
    ATTR{idVendor}=="0d9f", ATTR{idProduct}=="00a4", MODE="664", GROUP="nogroup"
    #  PowerCOM VGD - Vanguard  - usbhid-ups
    ATTR{idVendor}=="0d9f", ATTR{idProduct}=="00a5", MODE="664", GROUP="nogroup"
    #  PowerCOM BNT - Black Knight Pro  - usbhid-ups
    ATTR{idVendor}=="0d9f", ATTR{idProduct}=="00a6", MODE="664", GROUP="nogroup"
    #  Unitek Alpha 1200Sx  - nutdrv_qx
    ATTR{idVendor}=="0f03", ATTR{idProduct}=="0001", MODE="664", GROUP="nogroup"

    # Liebert
    #  Liebert PowerSure PSA UPS  - usbhid-ups
    ATTR{idVendor}=="10af", ATTR{idProduct}=="0001", MODE="664", GROUP="nogroup"
    #  Liebert PowerSure PSI 1440  - usbhid-ups
    ATTR{idVendor}=="10af", ATTR{idProduct}=="0004", MODE="664", GROUP="nogroup"
    #  Liebert GXT3  - usbhid-ups
    ATTR{idVendor}=="10af", ATTR{idProduct}=="0008", MODE="664", GROUP="nogroup"
    #  GE EP series  - nutdrv_qx
    ATTR{idVendor}=="14f0", ATTR{idProduct}=="00c9", MODE="664", GROUP="nogroup"

    # Legrand
    #  Legrand Keor SP  - usbhid-ups
    ATTR{idVendor}=="1cb0", ATTR{idProduct}=="0032", MODE="664", GROUP="nogroup"
    #  Legrand Daker DK / DK Plus  - nutdrv_qx
    ATTR{idVendor}=="1cb0", ATTR{idProduct}=="0035", MODE="664", GROUP="nogroup"
    #  Legrand Keor PDU  - usbhid-ups
    ATTR{idVendor}=="1cb0", ATTR{idProduct}=="0038", MODE="664", GROUP="nogroup"

    # Arduino
    #  Arduino Leonardo, Leonardo ETH and Pro Micro - usbhid-ups
    ATTR{idVendor}=="2341", ATTR{idProduct}=="0036", MODE="664", GROUP="nogroup"
    #  Arduino Leonardo, Leonardo ETH and Pro Micro - usbhid-ups
    ATTR{idVendor}=="2341", ATTR{idProduct}=="8036", MODE="664", GROUP="nogroup"

    # Arduino
    #  Arduino Leonardo, Leonardo ETH and Pro Micro - usbhid-ups
    ATTR{idVendor}=="2A03", ATTR{idProduct}=="0036", MODE="664", GROUP="nogroup"
    #  Arduino Leonardo, Leonardo ETH and Pro Micro - usbhid-ups
    ATTR{idVendor}=="2A03", ATTR{idProduct}=="0040", MODE="664", GROUP="nogroup"
    #  Arduino Leonardo, Leonardo ETH and Pro Micro - usbhid-ups
    ATTR{idVendor}=="2A03", ATTR{idProduct}=="8036", MODE="664", GROUP="nogroup"
    #  Arduino Leonardo, Leonardo ETH and Pro Micro - usbhid-ups
    ATTR{idVendor}=="2A03", ATTR{idProduct}=="8040", MODE="664", GROUP="nogroup"

    # AEG
    #  PROTECT B / NAS  - usbhid-ups
    ATTR{idVendor}=="2b2d", ATTR{idProduct}=="ffff", MODE="664", GROUP="nogroup"

    # Ever
    #  USB IDs device table  - usbhid-ups
    ATTR{idVendor}=="2e51", ATTR{idProduct}=="0000", MODE="664", GROUP="nogroup"
    #  USB IDs device table  - usbhid-ups
    ATTR{idVendor}=="2e51", ATTR{idProduct}=="ffff", MODE="664", GROUP="nogroup"

    # Salicru
    #  SLC TWIN PRO2<=3KVA per https://github.com/networkupstools/nut/issues/450  - usbhid-ups
    ATTR{idVendor}=="2e66", ATTR{idProduct}=="0201", MODE="664", GROUP="nogroup"
    #  SLC TWIN PRO2<=3KVA per https://github.com/networkupstools/nut/issues/450  - usbhid-ups
    ATTR{idVendor}=="2e66", ATTR{idProduct}=="0202", MODE="664", GROUP="nogroup"
    #  SLC TWIN PRO2<=3KVA per https://github.com/networkupstools/nut/issues/450  - usbhid-ups
    ATTR{idVendor}=="2e66", ATTR{idProduct}=="0203", MODE="664", GROUP="nogroup"
    #  https://www.salicru.com/sps-home.html  - usbhid-ups
    ATTR{idVendor}=="2e66", ATTR{idProduct}=="0300", MODE="664", GROUP="nogroup"

    # Powervar
    #  Powervar  - usbhid-ups
    ATTR{idVendor}=="4234", ATTR{idProduct}=="0002", MODE="664", GROUP="nogroup"
    #  Ablerex 625L USB (Note: earlier best-fit was "krauler_subdriver" before PR #1135)  - nutdrv_qx
    ATTR{idVendor}=="ffff", ATTR{idProduct}=="0000", MODE="664", GROUP="nogroup"

    LABEL="nut-usbups_rules_end"
  '';
}
