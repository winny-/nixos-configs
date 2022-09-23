{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./base.nix
    ./mosh.nix
  ];

  boot.kernelParams = [
    "console=tty1"
    "console=ttyS0,115200"
  ];
}
