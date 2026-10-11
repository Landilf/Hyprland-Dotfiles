{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, binutils
, makeWrapper
, alsa-lib
, at-spi2-atk
, gtk3
, libappindicator-gtk3
, libnotify
, libpulseaudio
, libsecret
, libuuid
, libXScrnSaver
, libXtst
, mesa
, nss
, pipewire
, xdg-utils
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lolka";
  version = "1.0.100";

  src = fetchurl {
    url = "https://storage.yandexcloud.net/lolka-electron/releases/Lolka_${finalAttrs.version}_amd64.deb";
    hash = "sha256-FcJdPEUxTYWds3U3ZNGw5tkdJSjEEO8HD1Akg738myw=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    binutils
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    gtk3
    libappindicator-gtk3
    libnotify
    libpulseaudio
    libsecret
    libuuid
    libXScrnSaver
    libXtst
    mesa
    nss
    pipewire
  ];

  unpackPhase = ''
    runHook preUnpack
    ar x "$src"
    tar -xf data.tar.xz
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/lib" "$out/share"
    cp -r opt/Lolka "$out/lib/lolka"
    cp -r usr/share/applications usr/share/icons "$out/share"
    substituteInPlace "$out/share/applications/lolka.desktop" \
      --replace-fail "Exec=/opt/Lolka/lolka" "Exec=lolka"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/lib/lolka/lolka" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"
    ln -s "$out/lib/lolka/lolka" "$out/bin/lolka"
  '';

  meta = {
    description = "Voice chat and screen sharing application";
    homepage = "https://lolka.app";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "lolka";
  };
})
