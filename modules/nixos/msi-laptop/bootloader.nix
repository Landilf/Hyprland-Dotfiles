{ inputs, pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
#    grub.useOSProber = true;

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

#    grub = {
#      enable = true;
#      efiSupport = true;
#      device = "nodev";
#      theme = inputs.nixos-grub-themes.packages.${pkgs.stdenv.hostPlatform.system}.hyperfluent;
#    };
  };

  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-19" "--long" ];
  boot.loader.systemd-boot.configurationLimit = 1;
}
