{ config, pkgs, ... }:

{
  # Define user accounts.
  users.users.landilf = {
    isNormalUser = true;
    description = "Jacopo";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  # Sets trusted users
  nix.settings.trusted-users = [ "root" "landilf"];
}
