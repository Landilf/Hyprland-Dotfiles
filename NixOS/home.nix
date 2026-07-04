{ config, pkgs, ... }:

	let
    jetbrainsVmOptions = pkgs.writeText "jetbrains.vmoptions" ''
      -javaagent:/home/landilf/ProgrammingSoftware/JetBrains/jetbra/ja-netfilter.jar=jetbrains 
      --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED 
      --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
	  '';

    # JetBrains IDEA wrapper
	  ideaVersion = "2025.2.6.1";
	  ideaUltimatePinned = pkgs.jetbrains.idea.overrideAttrs (_old: {
	    version = ideaVersion;
	    src = pkgs.fetchurl {
	      url = "https://download.jetbrains.com/idea/ideaIU-${ideaVersion}.tar.gz";
	      hash = "sha256-TOix8nLmQn3nCYmk5BQFSGuXxO8urN3Zv70bv5EtP7I=";
	    };
	  });
	  ideaUltimateWrapped = ideaUltimatePinned.overrideAttrs (old: {
	    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
	    postFixup =
	      (old.postFixup or "")
	      + ''
	        if [ -x "$out/bin/idea-ultimate" ]; then
	          wrapProgram "$out/bin/idea-ultimate" --set IDEA_VM_OPTIONS "${jetbrainsVmOptions}"
	        fi

	        if [ -x "$out/bin/idea" ]; then
	          wrapProgram "$out/bin/idea" --set IDEA_VM_OPTIONS "${jetbrainsVmOptions}"
	        fi
	      '';
	  });

	  # JetBrains PyCharm wrapper
	  pycharmVersion = "2025.2.6.1";
	  pycharmPinned = pkgs.jetbrains.pycharm.overrideAttrs (_old: {
	    version = pycharmVersion;
	    src = pkgs.fetchurl {
	      url = "https://download.jetbrains.com/python/pycharm-${pycharmVersion}.tar.gz";
	      hash = "sha256-OT7zpi34LbwI4g+RUyS/SYu/KJX+gtb3kOO4U96Psqc=";
	    };
	  });
	  pycharmBase = pycharmPinned;
    pycharmWrapped = pycharmBase.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
      postFixup =
        (old.postFixup or "")
        + ''
          for bin in "$out/bin/pycharm" "$out/bin/pycharm-community" "$out/bin/pycharm-professional"; do
            if [ -x "$bin" ]; then
              wrapProgram "$bin" --set PYCHARM_VM_OPTIONS "${jetbrainsVmOptions}"
            fi
          done
        '';
    });
	in
{

  imports = [
  ];

  home.stateVersion = "25.11";
  home.username = "landilf";
  home.homeDirectory = "/home/landilf";

  home.sessionVariables = {
    ANDROID_HOME = "${config.home.homeDirectory}/ProgrammingSoftware/Android/Sdk";
    ANDROID_SDK_ROOT = "${config.home.homeDirectory}/ProgrammingSoftware/Android/Sdk";
    ANDROID_USER_HOME = "${config.home.homeDirectory}/.android";
    ANDROID_EMULATOR_HOME = "${config.home.homeDirectory}/.android";
    ANDROID_AVD_HOME = "${config.home.homeDirectory}/.android/avd";
  };

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
      [ "msword.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
      [ "msword.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template" =
      [ "msword.desktop" ];
    "application/vnd.ms-word.document.macroEnabled.12" =
      [ "msword.desktop" ];
    "application/rtf" =
      [ "msword.desktop" ];

    # ---- Microsoft Excel ----
    "application/vnd.ms-excel" =
      [ "msexcel.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
      [ "msexcel.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template" =
      [ "msexcel.desktop" ];
    "application/vnd.ms-excel.sheet.macroEnabled.12" =
      [ "msexcel.desktop" ];
    "text/csv" =
      [ "msexcel.desktop" ];

    # ---- Microsoft PowerPoint ----
    "application/vnd.ms-powerpoint" =
      [ "mspowerpoint.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
      [ "mspowerpoint.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.template" =
      [ "mspowerpoint.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow" =
      [ "mspowerpoint.desktop" ];
    "application/vnd.ms-powerpoint.presentation.macroEnabled.12" =
      [ "mspowerpoint.desktop" ];

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

  # Android Studio Emulator fix
  xdg.desktopEntries.android-studio = {
    name = "Android Studio (stable channel)";
    comment = "The official Android IDE";
    categories = [ "Development" "IDE" ];
    # Force XWayland for Qt-based tools like the Android Emulator, and make sure
    # Android Studio and the emulator agree on SDK/adb paths.
    exec = "android-studio-rofi";
    icon = "android-studio";
    startupNotify = true;
    terminal = false;
    settings = {
      StartupWMClass = "jetbrains-studio";
    };
  };

  # Telegram override for rofi drun history/ranking.
  # Keep the same desktop id, but disable DBus activation so launches are
  # tracked like a normal app entry.
  xdg.desktopEntries."org.telegram.desktop" = {
    name = "Telegram";
    comment = "New era of messaging";
    categories = [ "Chat" "Network" "InstantMessaging" "Qt" ];
    exec = "Telegram -- %U";
    icon = "org.telegram.desktop";
    terminal = false;
    startupNotify = true;
    settings = {
      StartupWMClass = "TelegramDesktop";
      DBusActivatable = "false";
    };
  };

  # Firefox with pywalfox
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    nativeMessagingHosts = [ pkgs.pywalfox-native ];
    languagePacks= [ "ru" ];
  };

  # Chromium 
  programs.chromium.enable = true;

  # VSCodium defaults
  xdg.configFile."VSCodium/User/settings.json".text = builtins.toJSON {
    "python.defaultInterpreterPath" = "${config.home.homeDirectory}/ProgrammingSoftware/PythonVenv/bin/python";
    "security.workspace.trust.untrustedFiles" = "open";
    "git.decorations.enabled" = true;
    "git.autoRepositoryDetection" = "subFolders";
    "git.openRepositoryInParentFolders" = "always";
    "scm.diffDecorations" = "all";
  };
  
  # Fish shell configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_color_autosuggestion brblack
      set -U fish_greeting ""
    '';
    functions = {
      kitty-theme = ''
          for socket in /tmp/kitty-*
            kitty @ --to unix:$socket set-colors ~/.config/kitty/themes/Matugen.conf
          end
      '';
    };
    shellAliases = {
      adb = "~/ProgrammingSoftware/Android/Sdk/platform-tools/adb";
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
      dcuw = "docker compose -f ~/.config/windows-docker/compose.yaml up -d";
      dcdw = "docker compose -f ~/.config/windows-docker/compose.yaml down";
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

  # SwayOSD service
  services.swayosd.enable = true;

  # Bluetooth media buttons
  systemd.user.services.mpris-proxy = {
    Unit = {
      Description = "Bluetooth MPRIS Proxy";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.sdk-adb = {
    Unit = {
      Description = "Android SDK adb server";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${config.home.homeDirectory}/ProgrammingSoftware/Android/Sdk/platform-tools/adb nodaemon server";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
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
    (python3.withPackages (ps: with ps; [
      beautifulsoup4
      matplotlib
      numpy
      openpyxl
      pandas
      playwright
      plotly
      pymorphy3
      requests
      scikit-learn
      streamlit
      torch
      transformers
    ]))
    adw-gtk3
    android-studio
    (writeShellScriptBin "android-studio-rofi" ''
      export QT_QPA_PLATFORM=xcb
      export ANDROID_HOME="$HOME/ProgrammingSoftware/Android/Sdk"
      export ANDROID_SDK_ROOT="$ANDROID_HOME"
      export ANDROID_USER_HOME="$HOME/.android"
      export ANDROID_EMULATOR_HOME="$HOME/.android"
      export ANDROID_AVD_HOME="$HOME/.android/avd"
      export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
      exec android-studio "$@"
    '')
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
    drawio
    eza
    file-roller
    gimp
    git
    gnome-clocks
    grim
    gthumb
    heroic
    hypridle
    hyprlock
    hyprpicker
    hyprpolkitagent
    hyprshot
    hyprsunset
    imv
    ideaUltimateWrapped
    jq
    kdePackages.kamera
    nautilus
    nitch
    nwg-dock-hyprland
    nwg-look
    obs-cmd
    obsidian
    pamixer
    pavucontrol
    pycharmWrapped
    pywalfox-native
    slurp
    socat
    stow
    swaynotificationcenter
    awww
    telegram-desktop
    tesseract
    unimatrix
    wtype
    vscodium
    waybar
    wl-clip-persist
    wl-clipboard
    yazi
    zenity
  ];
}
