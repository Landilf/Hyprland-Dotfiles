{ config, pkgs, ... }:

{

  imports = [
    ./winapps.nix
  ];

  home.stateVersion = "25.11";
  home.username = "landilf";
  home.homeDirectory = "/home/landilf";

  # mimeApps
  xdg.mimeApps.enable = true;

  xdg.mimeApps.defaultApplications = {

    # Images
    "image/jpeg" = [ "imv.desktop" ];
    "image/png"  = [ "imv.desktop" ];
    "image/gif"  = [ "firefox.desktop" ];
    "image/webp" = [ "org.gnome.eog.desktop" ];
    "image/heif" = [ "imv.desktop" ];

    # Text / Code
    "text/plain" = [ "codium.desktop" ];
    "text/css" = [ "codium.desktop" ];
    "application/x-shellscript" = [ "codium.desktop" ];
    "application/x-zerosize" = [ "codium.desktop" ];
    "text/html" = [ "firefox.desktop" ];

    # Browser handlers
    "x-scheme-handler/http"  = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "application/pdf" = [ "firefox.desktop" ];

    # ---- Microsoft Word ----
    "application/msword" =
      [ "word-o365.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
      [ "word-o365.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template" =
      [ "word-o365.desktop" ];

    # ---- Microsoft Excel ----
    "application/vnd.ms-excel" =
      [ "excel-o365.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
      [ "excel-o365.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template" =
      [ "excel-o365.desktop" ];

    # ---- Microsoft PowerPoint ----
    "application/vnd.ms-powerpoint" =
      [ "powerpoint-o365.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
      [ "powerpoint-o365.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.template" =
      [ "powerpoint-o365.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow" =
      [ "powerpoint-o365.desktop" ];

    # Audio
    "audio/mpeg" = [ "org.gnome.Decibels.desktop" ];

    # File manager
    "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

    # Video
    "video/mp4" = [ "mpv.desktop" ];
    "video/x-matroska" = [ "mpv.desktop" ];
    "video/webm" = [ "mpv.desktop" ];
    "video/ogg" = [ "mpv.desktop" ];
    "video/quicktime" = [ "mpv.desktop" ];
    "video/x-flv" = [ "mpv.desktop" ];
    "video/x-msvideo" = [ "mpv.desktop" ];
    "video/x-ms-wmv" = [ "mpv.desktop" ];
    "video/mpeg" = [ "mpv.desktop" ];
  };

  # Firefox with pywalfox
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.pywalfox-native ];
    languagePacks= [ "ru" ];
  };

  # Chromium 
  programs.chromium.enable = true;
  
  # Fish shell configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_color_autosuggestion brblack
      set -U fish_greeting ""
    '';
    functions = {
      ps5 = ''
          set capacity (cat /sys/class/power_supply/ps-controller-battery-4c:b9:9b:cc:ba:12/capacity)
          set battery_status (cat /sys/class/power_supply/ps-controller-battery-4c:b9:9b:cc:ba:12/status)
    
          # Simple bar
          set bar_length 20
          set filled (math "round($capacity / 100 * $bar_length)")
          set empty (math "$bar_length - $filled")
    
          set bar (string repeat -n $filled '█')(string repeat -n $empty '░')
    
          echo "🎮 PS5 Controller: [$bar] $capacity% ($battery_status)"
      '';
      kitty-theme = ''
          for socket in /tmp/kitty-*
            kitty @ --to unix:$socket set-colors ~/.config/kitty/themes/Matugen.conf
          end
      '';
    };
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/Hyprland-Dotfiles/NixOS#nix-btw";
      nrb = "sudo nixos-rebuild boot --flake ~/Hyprland-Dotfiles/NixOS#nix-btw";
      nfu = "nix flake update";
      nce = "vim ~/Hyprland-Dotfiles/NixOS/configuration.nix";
      nhe = "vim ~/Hyprland-Dotfiles/NixOS/home.nix";
      nfe = "vim ~/Hyprland-Dotfiles/NixOS/flake.nix";
      try = "nix-shell -p";
      ncg = "sudo nix-collect-garbage -d";
      cff = "reset && nitch";  
      ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
      ls = "eza -la";
      dcu = "docker compose -f ~/winapps/docker-compose.yaml up -d";
      dcd = "docker compose -f ~/winapps/docker-compose.yaml down";

    };
  };
  
  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Git configuration (add your details)
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Landilf";
        email = "vladrumin4@gmail.com";
      };
    };
  };

  # KDE Connect configuration
  services.kdeconnect = {
    package = 
      pkgs.kdePackages.kdeconnect-kde
    ;
    enable = true;
    indicator = true;
  };
  
  # OBS for screen recording
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
    package = pkgs.obs-studio.override {
      cudaSupport = true; 
    };
  };

  # Video Player
  programs.mpv = {
    enable = true;
  };
  
  # Kitty Terminal configuration
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    settings = {
      include = "current-theme.conf";
      font_size = 14;
      cursor_trail = 5;
      scrollback_indicator_opacity = 0;
      window_padding_width = 20;
      placement_strategy = "top-left";
      hide_window_decorations = "yes";
      resize_debounce_time = "0 0";
      confirm_os_window_close = 0;
      background_opacity = 0.8;
      background_blur = 0;
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      "map shift+cmd+plus" = "change_font_size all +2.0";
      "map shift+cmd+minus" = "change_font_size all -2.0";
      "map shift+cmd+backspace" = "change_font_size all 14";
    };
    font = {
      size = 14;
      name = "JetBrains Mono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
  };
  programs.rofi = {
    enable = true;
    plugins = [ pkgs.rofi-calc ];
    package = pkgs.rofi;
    configPath = ".config/rofi/.hm-config.rasi";
  };

  # User-specific packages
  home.packages = with pkgs; [
    adw-gtk3
    android-studio
    ani-cli
    asciiquarium-transparent
    blueman
    brightnessctl
    cava
    cbonsai
    cliphist
    dconf-editor
    decibels
    discord
    eza
    file-roller
    gimp
    git
    gnome-clocks
    gthumb
    heroic
    hypridle
    hyprlock
    hyprpicker
    hyprpolkitagent
    hyprshot
    imv
    jetbrains.idea
    kdePackages.kamera
    nautilus
    nitch
    nwg-dock-hyprland
    nwg-look
    obsidian
    pamixer
    pavucontrol
    python3
    python3Packages.pip
    python3Packages.virtualenv
    pywalfox-native
    stow
    swaynotificationcenter
    swww
    telegram-desktop
    unimatrix
    vscodium
    waybar
    winboat
    wl-clip-persist
    wl-clipboard
    yazi
    zenity
  ];
}