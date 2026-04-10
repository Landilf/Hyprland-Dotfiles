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
    RDP_FLAGS="/cert:tofu /sound /microphone /drive:home,/home/landilf"

    FREERDP_COMMAND="${pkgs.freerdp}/bin/xfreerdp"
  '';
}