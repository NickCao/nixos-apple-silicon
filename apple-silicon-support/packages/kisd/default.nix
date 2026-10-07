{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "kisd";
  version = "1.1.0-unstable-2026-09-27";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "kisd";
    rev = "28608c038bc994a672fb45d3aac38a4008bafbd9";
    hash = "sha256-oKrKYYFYHJBw62liDSaN+7cJmjEVDjxJhZwTJufC3Ik=";
  };

  cargoHash = "sha256-InJ0zfR00z8NyRc04ku1FO+jJSJB2eluelAZtlYpJc0=";

  postInstall = ''
    install -Dm644 etc/udev/rules.d/85-apple-debugusb.rules \
      $out/lib/udev/rules.d/85-apple-debugusb.rules
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=main" ];
  };

  meta = {
    description = "Kanzi-in-System / DebugUSB UART support for Linux hosts";
    homepage = "https://github.com/AsahiLinux/kisd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nickcao ];
    platforms = lib.platforms.linux;
    mainProgram = "kisd";
  };
}
