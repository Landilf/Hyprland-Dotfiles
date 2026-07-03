#! /bin/sh

dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
ln -sfn ~/.config/RofiScripts/Walls-light/wall.sh ~/.config/RofiScripts/WallpaperChanger/wall.sh
ln -sfn ~/.config/RofiScripts/Walls-light/wallrandom.sh ~/.config/RofiScripts/WallpaperChanger/wallrandom.sh
matugen image ~/.config/RofiScripts/Walls-light/Wall -m light -t scheme-fidelity --fallback-color grey
ln -sfn ~/.config/RofiScripts/Walls-light/Wall ~/.config/RofiScripts/WallpaperChanger/Wall

prism_cfg="$HOME/.local/share/PrismLauncher/prismlauncher.cfg"
if [ -f "$prism_cfg" ]; then
    if grep -q '^ApplicationTheme=' "$prism_cfg"; then
        sed -i 's/^ApplicationTheme=.*/ApplicationTheme=bright/' "$prism_cfg"
    else
        printf '\nApplicationTheme=bright\n' >> "$prism_cfg"
    fi

    if grep -q '^IconTheme=' "$prism_cfg"; then
        sed -i 's/^IconTheme=.*/IconTheme=flat/' "$prism_cfg"
    else
        printf 'IconTheme=flat\n' >> "$prism_cfg"
    fi
fi

ln -sfn ~/.config/RofiScripts/Dark-Light-Mode/Dark/dark.sh ~/.config/swaync/scripts/changetheme.sh
