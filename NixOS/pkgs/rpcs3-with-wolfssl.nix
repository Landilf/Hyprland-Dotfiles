{ lib
, pkgs
}:

let
  # Keep a local compatibility copy so RPCS3 can keep loading the legacy wolfSSL ABI.
  wolfsslCompat = pkgs.callPackage ./wolfssl.nix { };
  rpcs3Patched = pkgs.rpcs3.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      mkdir -p "$out/lib"
      if [ -f ./3rdparty/fusion/fusion/Fusion/libFusion.so ]; then
        install -Dm755 ./3rdparty/fusion/fusion/Fusion/libFusion.so "$out/lib/libFusion.so"
      fi
    '';
  });
in
pkgs.symlinkJoin {
  name = "rpcs3-with-wolfssl";
  paths = [ rpcs3Patched ];
  nativeBuildInputs = [ pkgs.makeWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/rpcs3" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ rpcs3Patched wolfsslCompat ]}"
  '';
}
