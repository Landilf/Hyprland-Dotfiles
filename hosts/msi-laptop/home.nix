{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager
  ];

  home = { 
    username = "landilf";
    homeDirectory = "/home/landilf";
    stateVersion = "24.05"; # Do not change
  };

  home.packages = with pkgs; [
    dconf
  ];

  home.sessionVariables = {
    TERMINAL = "kitty";
    EDITOR = "nvim";
    VISUAL = "nvim";
    HYPRSHOT_DIR = "/home/landilf/Screenshots";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
