{ config, pkgs, inputs, pkgs-unstable, system, winapps, lib, ... }:

{

  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages;

  # Time Settings
  time.hardwareClockInLocalTime = false;

  # Boot customization
  boot.plymouth = {
    enable = true;
    themePackages = [ pkgs.adi1090x-plymouth-themes ];
    theme = "lone";
  };

  boot.kernelParams = [ "quiet" "splash" "boot.shell_on_fail" "loglevel=3" "rd.systemd.show_status=false" "rd.udev.log_level=0" "udev.log_priority=0" "resume=UUID=c0428711-04a3-4adf-998d-d88af1d26e71" ];
  boot.resumeDevice = "/dev/disk/by-uuid/c0428711-04a3-4adf-998d-d88af1d26e71";
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Networking
  networking.hostName = "nix-btw";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.firewall.enable = true;

  # Hibernation when closing the laptop lid
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
  };

  # Power profiles
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      CPU_MAX_PERF_ON_AC = 100;
      CPU_MAX_PERF_ON_BAT = 70;

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  # Throne Settings
  security.wrappers.Throne = {
    source = "${pkgs-unstable.throne}/bin/Throne";
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin+ep";
  };
  
  # KDE Connect Configuration
  programs.kdeconnect.package = pkgs.kdePackages.kdeconnect-kde;
  programs.kdeconnect.enable = true;

  # Localization
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Keyboard
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
  };
  console.keyMap = "us";

  # User account
  users.users.landilf = {
    isNormalUser = true;
    description = "Landilf";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "input" "kvm" "adbusers" ];
    shell = pkgs.fish;
  };

  # SwayOSD udev rules
  services.udev.packages = [ pkgs.swayosd ];

  # Home Manager
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";

  # System-wide settings
  nixpkgs.config.allowUnfree = true;
  zramSwap.enable = true;

  # Desktop Environment
  programs.hyprland.enable = true;
  programs.dconf.enable = true;
  
  # Shell (required for user shell)
  programs.fish.enable = true;

  # SSH configuration
  programs.ssh.startAgent = true;

  # Java configuration
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  # Docker configuration
  virtualisation.docker.enable = true;
  
  # Gaming
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamescope = {
    enable = true;
    package = pkgs.gamescope;
  };

  # Flatpak
  services.flatpak.enable = false;

  # Hardware
  hardware.bluetooth.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  hardware.opentabletdriver = {
    enable = false;
  };

  # NVIDIA + AMD Prime
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:54:0:0";
    };
  };

  # OpenRGB
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
  systemd.services.openrgb.wantedBy = lib.mkForce [];

  # Audio
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Display Manager
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    wayland.enable = true;
    extraPackages = with pkgs; [ 
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      kdePackages.qtbase
    ]; 
  };

  # XDG Portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
  
  # GVFS for trash support in file managers
  services.gvfs.enable = true;

  # System packages (only system-level stuff)
  environment.systemPackages = 
    (with pkgs-unstable; [
      codex
      easyeffects
      throne
      yandex-music
    ])
    ++ [
      winapps.packages."${config.nixpkgs.hostPlatform.system}".winapps
      winapps.packages."${config.nixpkgs.hostPlatform.system}".winapps-launcher
    ]
    ++ (with pkgs; [
      inputs.matugen.packages.${config.nixpkgs.hostPlatform.system}.default
      inputs.prism-cracked.packages.${config.nixpkgs.hostPlatform.system}.prismlauncher
      alsa-plugins
      bluez
      bubblewrap
      docker
      docker-compose
      flameshot
      font-awesome
      freerdp
      fzf
      gnome-themes-extra
      kdePackages.kstatusnotifieritem
      kdePackages.qt6ct
      killall
      lazydocker
      lazygit
      libnotify
      libqalculate
      libsForQt5.qt5ct
      mangohud
      mission-center
      neo
      nix-search-tv
      openrgb-with-all-plugins
      p7zip
      powertop
      ppsspp-sdl-wayland
      protonplus
      rpcs3
      sddm-astronaut
      scanmem
      tenacity
      vim
      winetricks
      xrandr
    ]);

  # Codex CLI expects a system bubblewrap at /usr/bin/bwrap.
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/bwrap - - - - ${pkgs.bubblewrap}/bin/bwrap"
  ];

  # Fonts
  fonts.packages = with pkgs; [ 
    noto-fonts
    adwaita-fonts
    nerd-fonts.jetbrains-mono 
    noto-fonts-cjk-sans
  ];
  
  # Udev Settings

  # Teevolution Terra
 services.udev.extraRules = ''
    # Teevolution Terra
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="f523", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="f522", MODE="0666", TAG+="uaccess" 

    # Wooting One Legacy
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE="0666", TAG+="uaccess"

    # Wooting One update mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2402", MODE="0666", TAG+="uaccess"

    # Wooting Two Legacy
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE="0666", TAG+="uaccess"

    # Wooting Two update mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2403", MODE="0666", TAG+="uaccess"

    # Generic Wooting devices
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", MODE="0666", TAG+="uaccess"
  '';

  # Nix optimization
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Nix settings
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
