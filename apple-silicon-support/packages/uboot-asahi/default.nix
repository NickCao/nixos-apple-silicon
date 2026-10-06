{
  lib,
  fetchFromGitHub,
  buildUBoot,
  m1n1,
  defconfig ? "apple_j873_defconfig",
}:

(buildUBoot rec {
  src = fetchFromGitHub {
    owner = "aurora-silicon";
    repo = "u-boot";
    rev = "55aaa060bfabefc2247d38fd1ede9341c3786899";
    hash = "sha256-+Utb4H3UI6J6EDXsUWdfVPPTJJSQrXP7vdfgzpsO5GQ=";
  };
  version = "2026.07-unstable-2026-10-03";

  inherit defconfig;
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [
    "u-boot-nodtb.bin.gz"
    "m1n1-u-boot.bin"
  ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version}"
    CONFIG_VIDEO_FONT_4X6=n
    CONFIG_VIDEO_FONT_8X16=n
    CONFIG_VIDEO_FONT_SUN12X22=n
    CONFIG_VIDEO_FONT_16X32=y
    CONFIG_CMD_BOOTMENU=y
  '';
}).overrideAttrs
  (o: {
    # nixos's downstream patches are not applicable
    patches = [
    ];

    preInstall = ''
      # compress so that m1n1 knows U-Boot's size and can find things after it
      gzip -n u-boot-nodtb.bin
      cat ${m1n1}/lib/m1n1/m1n1.bin arch/arm/dts/t[68]*.dtb u-boot-nodtb.bin.gz > m1n1-u-boot.bin
    '';
  })
