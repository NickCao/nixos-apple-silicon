{
  m1n1,
  fetchFromGitHub,
  nix-update-script,
}:

m1n1.overrideAttrs (
  finalAttrs: previousAttrs: {
    version = "unstable-2026-10-03";

    src = fetchFromGitHub {
      owner = "aurora-silicon";
      repo = "m1n1";
      rev = "049a304e87c4baabd0fa51face58543dcfb45f7b";
      hash = "sha256-rDVMnllz6oEVXNQQqSpPvrUhp1LMbx5g/QBAC9xPKxA=";
    };

    cargoDeps = m1n1.rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version;
      src = "${finalAttrs.src}/rust";
      sourceRoot = "rust";
      hash = "sha256-7G9aTQEiQ8ocsY0gSoBg9A2cusfqR4a1nhFikpWMXAA=";
    };

    env.M1N1_VERSION_TAG = "${finalAttrs.version}-${builtins.substring 0 12 finalAttrs.src.rev}";

    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script {
        extraArgs = [ "--version=branch=aurora-wip" ];
      };
    };

    meta = previousAttrs.meta // {
      homepage = "https://github.com/aurora-silicon/m1n1";
      changelog = "https://github.com/aurora-silicon/m1n1/commits/${finalAttrs.src.rev}";
    };
  }
)
