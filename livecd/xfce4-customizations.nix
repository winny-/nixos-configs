{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ../common/workstation.nix
  ];

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.winston = {
    password = "install nixos";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+J0puhRQksmrEQgL6pkb4DW/q5eap2sY6GKMegPb6Jy644yBO8ADsTctNG8Rt4uJE62Uct1f2WXAn4dzRDMhSgvQO0qJ9LO4TxLiyAQe0Wiq7R6joORH0ZfpN222epaK2ZhxKj2UCE2n3Xr6wxmYDH3RoE2whL8QtsBp4QHe9vPbiszm2vMNVIQ3YteJ8NVNX9DGEAiBoX89jUT8Gw9IBTmNDaI1Rw/w9S9JGczBF8vfzB2zCCMQWhk/oTB7hVH/Y9uG+M8rq8X1vsxqGaeonvTZUzjeLCQPYDx0MHLTmVtY8DmaL/9aXTrYiVIxffiedWimQqL14OdygQOkYfY2X winston@winston-one"
    ];
  };

  isoImage.edition = "xfce";
}
