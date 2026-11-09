{ lib
, stdenvNoCC
, requireFile
, makeDesktopItem
, copyDesktopItems
, steam-run
, archiveHash ? "sha256-BwyG/T8fJLw4F3ZEMIFnclEF/XCTCLVqSLimhq1R54c="
, archiveName ? "School-0.982-linux_BugFix7.tar.bz2"
, version ? "0.982-bugfix7"
}:

stdenvNoCC.mkDerivation {
  pname = "schoolgame";
  inherit version;

  src = requireFile {
    name = archiveName;
    hash = archiveHash;
    url = "https://kaitosi11.itch.io/schoolgame";
  };

  nativeBuildInputs = [ copyDesktopItems ];
  dontBuild = true;
  dontPatchShebangs = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/schoolgame" "$out/bin"
    cp -r . "$out/share/schoolgame/"

    # Use the distribution's bundled Ren'Py rather than a different engine version.
    mapfile -d "" launchers < <(find "$out/share/schoolgame" -maxdepth 1 -name '*.sh' -print0)
    if [ "''${#launchers[@]}" -ne 1 ]; then
      echo "Expected exactly one Ren'Py launcher in the Linux distribution" >&2
      exit 1
    fi
    chmod +x "''${launchers[0]}"

    cat > "$out/bin/schoolgame" <<EOF
    #!${stdenvNoCC.shell}
    set -eu
    save_dir="\$HOME/Games/SchoolGame/saves"
    state_dir="\''${XDG_STATE_HOME:-\$HOME/.local/state}/schoolgame"
    mkdir -p "\$save_dir" "\$state_dir"
    export RENPY_LOG_BASE="\$state_dir"
    export RENPY_MULTIPERSISTENT="\$state_dir"
    export RENPY_SCREENSHOT_PATTERN="\$HOME/Games/SchoolGame/screenshot%04d.jpg"
    exec ${lib.getExe steam-run} "''${launchers[0]}" "$out/share/schoolgame" --savedir "\$save_dir" "\$@"
    EOF
    chmod +x "$out/bin/schoolgame"
    runHook postInstall
  '';

  desktopItems = [ (makeDesktopItem {
    name = "schoolgame";
    desktopName = "School Game";
    exec = "schoolgame";
    icon = "applications-games";
    categories = [ "Game" ];
    terminal = false;
  }) ];

  meta = {
    description = "School Game";
    homepage = "https://kaitosi11.itch.io/schoolgame";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "schoolgame";
  };
}
