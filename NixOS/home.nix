{ config, pkgs, inputs, ... }:

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

    quickshellOverviewConfig = pkgs.writeText "quickshell-overview-config.json" (builtins.toJSON {
      appearance = {
        colorSource = "matugen";
        font.family = {
          main = "JetBrains Mono Nerd Font";
          title = "JetBrains Mono Nerd Font";
          expressive = "JetBrains Mono Nerd Font";
        };
      };
      overview = {
        rows = 2;
        columns = 5;
        hideEmptyRows = true;
        previewsEnabled = true;
        previewMode = "live";
        includeInactiveMonitorPreviews = true;
        showSpecialWorkspaces = true;
        scrolling.enable = false;
      };
    });

    # Include the config in the same source tree: a separate nested home.file
    # entry loses to the recursive overview link during Home Manager activation.
    # Guard empty colors during QML startup and avoid requesting the missing
    # fallback icon when an application icon is unavailable.
    quickshellOverview = pkgs.runCommand "quickshell-overview-patched" { } ''
      cp -R ${inputs.quickshell-overview}/. "$out"
      chmod u+w "$out"
      cp --remove-destination ${quickshellOverviewConfig} "$out/config.json"
      substituteInPlace "$out/common/functions/ColorUtils.qml" \
        --replace-fail 'function applyAlpha(color, alpha) {' 'function applyAlpha(color, alpha) { if (!color) return "transparent";'
      substituteInPlace "$out/modules/overview/OverviewWindow.qml" \
        --replace-fail 'property var iconPath: iconName.length > 0 ? Quickshell.iconPath(iconName, "image-missing") : ""' 'property var iconPath: iconName.length > 0 ? Quickshell.iconPath(iconName) : ""'
    '';
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
    # Avoid waiting on an unavailable IPv6 localhost when the adb server restarts.
    ADB_SERVER_SOCKET = "tcp:127.0.0.1:5037";
  };

  # Keep the overview module and its config pinned through flake.lock.
  home.file.".config/quickshell/overview" = {
    source = quickshellOverview;
    recursive = true;
  };

  # mimeApps
  xdg.mimeApps.enable = true;

  # Throne is started once by Hyprland, which places it on special:magic.
  # This override prevents the duplicate XDG autostart invocation.
  xdg.configFile."autostart/Throne.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Hidden=true
  '';

  # Keep XDG downloads aligned with the existing English-named directory.
  # Home Manager makes user-dirs.dirs immutable, so locale updates cannot
  # recreate an unused Russian-named Downloads folder.
  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    setSessionVariables = false;
    download = "${config.home.homeDirectory}/Downloads";
  };

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

    # Office files: use the stable desktop IDs maintained by ArtCraft Launcher.
    "application/msword" = [ "ai.storyteller.wordcraft.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "ai.storyteller.wordcraft.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = [ "ai.storyteller.wordcraft.desktop" ];
    "application/vnd.ms-word.document.macroEnabled.12" = [ "ai.storyteller.wordcraft.desktop" ];
    "application/rtf" = [ "ai.storyteller.wordcraft.desktop" ];
    "text/rtf" = [ "ai.storyteller.wordcraft.desktop" ];
    "application/vnd.oasis.opendocument.text" = [ "ai.storyteller.wordcraft.desktop" ];

    "application/vnd.ms-excel" = [ "ai.storyteller.gridcraft.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "ai.storyteller.gridcraft.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = [ "ai.storyteller.gridcraft.desktop" ];
    "application/vnd.ms-excel.sheet.macroEnabled.12" = [ "ai.storyteller.gridcraft.desktop" ];
    "application/vnd.oasis.opendocument.spreadsheet" = [ "ai.storyteller.gridcraft.desktop" ];
    "text/csv" = [ "ai.storyteller.gridcraft.desktop" ];

    "application/vnd.ms-powerpoint" = [ "ai.storyteller.deckcraft.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "ai.storyteller.deckcraft.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.template" = [ "ai.storyteller.deckcraft.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = [ "ai.storyteller.deckcraft.desktop" ];
    "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = [ "ai.storyteller.deckcraft.desktop" ];

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

  xdg.desktopEntries.rpcs3-latest = {
    name = "RPCS3 0.0.42";
    genericName = "PlayStation 3 Emulator";
    comment = "An open-source PlayStation 3 emulator/debugger written in C++.";
    categories = [ "Game" "Emulator" ];
    exec = "rpcs3-latest";
    icon = "rpcs3";
    terminal = false;
    startupNotify = true;
    settings = {
      Keywords = "PS3;Playstation;";
      StartupWMClass = "rpcs3";
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
    policies.Preferences = {
      # Nautilus can need over one second to activate through FileManager1.
      # Wait for ShowItems instead of opening Downloads through the fallback.
      "widget.gtk.file-manager-show-items-timeout-ms" = 3000;
    };
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
      region = ''
        set -l country (${pkgs.curl}/bin/curl \
          --connect-timeout 3 \
          --max-time 8 \
          --silent \
          --show-error \
          --fail \
          https://www.cloudflare.com/cdn-cgi/trace \
          | ${pkgs.gnugrep}/bin/grep '^loc=' \
          | ${pkgs.coreutils}/bin/cut -d= -f2)

        if test -z "$country"
          echo 'Не удалось определить страну внешнего IP.' >&2
          return 1
        end

        echo $country
      '';
      codex = ''
        # The request follows the system route, so it reflects the active VPN exit.
        set -l country (region)
        if test -z "$country"
          return 1
        end

        if test "$country" = RU
          echo 'Codex не запущен: внешний IP определяется как RU. Включи VPN в Throne.' >&2
          return 1
        end

        command codex $argv
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
      # Override ADB_SERVER_SOCKET for the listener: adb cannot bind a named host.
      ExecStart = "${config.home.homeDirectory}/ProgrammingSoftware/Android/Sdk/platform-tools/adb -L tcp:5037 nodaemon server";
      ExecStartPost = "${pkgs.coreutils}/bin/timeout 10 ${pkgs.bash}/bin/bash -c 'until ${config.home.homeDirectory}/ProgrammingSoftware/Android/Sdk/platform-tools/adb -H 127.0.0.1 start-server; do sleep 0.1; done'";
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
    (pkgs.callPackage ./pkgs/artcraft-launcher.nix { })
    (pkgs.callPackage ./pkgs/schoolgame.nix { })
    (pkgs.callPackage ./pkgs/snowhush.nix { })
    # Local menu scripts need Python's standard library; project dependencies
    # live in the Jupyter and ReviewAnalyzer containers.
    python3
    adw-gtk3
    android-studio
    (writeShellScriptBin "android-studio-rofi" ''
      export QT_QPA_PLATFORM=xcb
      export ANDROID_HOME="$HOME/ProgrammingSoftware/Android/Sdk"
      export ANDROID_SDK_ROOT="$ANDROID_HOME"
      export ANDROID_USER_HOME="$HOME/.android"
      export ANDROID_EMULATOR_HOME="$HOME/.android"
      export ANDROID_AVD_HOME="$HOME/.android/avd"
      export ADB_SERVER_SOCKET=tcp:127.0.0.1:5037
      export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
      ${pkgs.systemd}/bin/systemctl --user start sdk-adb.service || exit 1
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
    quickshell
    qt6.qtwayland
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
