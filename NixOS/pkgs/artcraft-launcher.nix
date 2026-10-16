{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, libglvnd
, vulkan-loader
, wayland
, libxkbcommon
, libx11
, libxcursor
, libxi
, libxrandr
, xdg-utils
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "artcraft-launcher";
  version = "0.4.1";

  src = fetchurl {
    url = "https://github.com/storytold/craft-launcher/releases/download/v${finalAttrs.version}/artcraft-launcher-${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-Ki7lHWm9uBdKKkjzApf9v6RgtuhzfDVmobbsRvgx+kA=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r bin share "$out/"
    substituteInPlace "$out/share/applications/ai.storyteller.artcraft-launcher.desktop" \
      --replace-fail 'Exec=artcraft-launcher' "Exec=$out/bin/artcraft-launcher"
    runHook postInstall
  '';

  # winit and the GPU backends load these libraries dynamically.
  postFixup = ''
    wrapProgram "$out/bin/artcraft-launcher" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        libglvnd vulkan-loader wayland libxkbcommon
        libx11 libxcursor libxi libxrandr
      ]}" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"
  '';

  meta = {
    description = "Install, update and launch apps from the Craft App Suite";
    homepage = "https://github.com/storytold/craft-launcher";
    license = with lib.licenses; [ mit asl20 ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "artcraft-launcher";
  };
})
