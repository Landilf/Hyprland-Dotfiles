{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, util-linux
, openssl
, cacert
, variant ? "all"
, extraConfigureFlags ? [ ]
, enableARMCryptoExtensions ?
    stdenv.hostPlatform.isAarch64
    && ((builtins.match "^.*\\+crypto.*$" stdenv.hostPlatform.gcc.arch) != null)
, enableLto ? !(stdenv.hostPlatform.isStatic || stdenv.cc.isClang)
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wolfssl-${variant}";
  version = "5.8.4";

  src = fetchFromGitHub {
    owner = "wolfSSL";
    repo = "wolfssl";
    tag = "v${finalAttrs.version}-stable";
    hash = "sha256-vfJKmDdM0r591t5GnuSS7NyiUYXCQOTKbWLVydB3N9s=";
  };

  postPatch = ''
    patchShebangs ./scripts
    substituteInPlace scripts/ocsp-stapling2.test \
      --replace '"linux-gnu"' '"linux-"'
  '';

  configureFlags = [
    "--enable-${variant}"
    "--enable-reproducible-build"
  ]
  ++ lib.optionals (variant == "all") [
    "--enable-pkcs11"
    "--enable-writedup"
    "--enable-base64encode"
  ]
  ++ [
    "--enable-bigcache"
    "--enable-sp=yes${lib.optionalString (stdenv.hostPlatform.isx86_64 || stdenv.hostPlatform.isAarch) ",asm"}"
    "--enable-sp-math-all"
    "--enable-harden"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isx86_64) [
    "--enable-intelasm"
    "--enable-aesni"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isAarch64) [
    (if enableARMCryptoExtensions then "--enable-armasm=inline" else "--disable-armasm")
  ]
  ++ extraConfigureFlags;

  hardeningDisable = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    "zerocallusedregs"
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString enableLto "-flto";
  env.NIX_LDFLAGS_COMPILE = lib.optionalString enableLto "-flto";
  env.WOLFSSL_EXTERNAL_TEST = "0";

  outputs = [
    "dev"
    "doc"
    "lib"
    "out"
  ];

  nativeBuildInputs = [
    autoreconfHook
    util-linux
  ];

  doCheck = !stdenv.hostPlatform.isLoongArch64;

  nativeCheckInputs = [
    openssl
    cacert
  ];

  postInstall = ''
    moveToOutput bin/wolfssl-config "$dev"
    mkdir -p "$out"
  '';

  meta = {
    description = "Small, fast, portable implementation of TLS/SSL for embedded devices";
    mainProgram = "wolfssl-config";
    homepage = "https://www.wolfssl.com/";
    changelog = "https://github.com/wolfSSL/wolfssl/releases/tag/v${finalAttrs.version}-stable";
    platforms = lib.platforms.all;
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      fab
      vifino
    ];
  };
})
