{ config, pkgs, ... }:

{
  xdg.configFile."winapps/winapps.conf".text = ''
    # [WINDOWS USERNAME]
    RDP_USER="landilf"

    # [WINDOWS PASSWORD]
    RDP_PASS="2891"

    # [WINDOWS IPV4 ADDRESS]
    RDP_IP="127.0.0.1"

    # [WINAPPS BACKEND]
    WAFLAVOR="docker"

    # [DISPLAY SCALING FACTOR]
    # RDP_SCALE="100"

    # [ADDITIONAL FREERDP FLAGS]
    HIDEF="off"
    # Prefer SDL client on Hyprland/Wayland (xfreerdp via Xwayland can freeze),
    # disable Kerberos (no default realm), and avoid AVC/GFX paths that often
    # trigger RemoteApp freezes.
    #
    # NOTE: WinApps itself adds `+home-drive` during setup/launch, so we do not
    # add a duplicate `/drive:home,...` mapping here.
    RDP_FLAGS="/auth-pkg-list:!kerberos /sound /microphone /gdi:sw /gfx:AVC444:off /gfx:AVC420:off"

    # Wrapper forces `SDL_RENDER_DRIVER=software` and runs `sdl-freerdp`.
    FREERDP_COMMAND="$HOME/Hyprland-Dotfiles/.local/bin/sdl-freerdp-winapps"
  '';
}
