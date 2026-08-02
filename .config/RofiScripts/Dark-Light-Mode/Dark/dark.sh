#! /bin/sh

dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
ln -sfn ~/.config/RofiScripts/Walls/wall.sh ~/.config/RofiScripts/WallpaperChanger/wall.sh
ln -sfn ~/.config/RofiScripts/Walls/wallrandom.sh ~/.config/RofiScripts/WallpaperChanger/wallrandom.sh
matugen image ~/.config/RofiScripts/Walls/Wall -m dark -t scheme-fidelity --fallback-color grey
ln -sfn ~/.config/RofiScripts/Walls/Wall ~/.config/RofiScripts/WallpaperChanger/Wall

prism_cfg="$HOME/.local/share/PrismLauncher/prismlauncher.cfg"
if [ -f "$prism_cfg" ]; then
    if grep -q '^ApplicationTheme=' "$prism_cfg"; then
        sed -i 's/^ApplicationTheme=.*/ApplicationTheme=dark/' "$prism_cfg"
    else
        printf '\nApplicationTheme=dark\n' >> "$prism_cfg"
    fi

    if grep -q '^IconTheme=' "$prism_cfg"; then
        sed -i 's/^IconTheme=.*/IconTheme=flat_white/' "$prism_cfg"
    else
        printf 'IconTheme=flat_white\n' >> "$prism_cfg"
    fi
fi

ln -sfn ~/.config/RofiScripts/Dark-Light-Mode/Light/light.sh ~/.config/swaync/scripts/changetheme.sh
