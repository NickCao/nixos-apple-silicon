{
  lib,
  callPackage,
  linuxPackagesFor,
  _kernelPatches ? [ ],
}@args:

let
  extraArgs = lib.removeAttrs args [
    "lib"
    "callPackage"
    "linuxPackagesFor"
    "_kernelPatches"
  ];

  linux-asahi-pkg =
    {
      stdenv,
      lib,
      fetchFromGitHub,
      buildLinux,
      ...
    }:
    buildLinux (
      lib.recursiveUpdate rec {
        inherit stdenv lib;

        pname = "linux-asahi";
        version = "7.1.12";
        modDirVersion = version;
        extraMeta.branch = "7.1";

        src = fetchFromGitHub {
          owner = "aurora-silicon";
          repo = "linux";
          rev = "f9572b54204e2cd81c764ce8bdaf0fa1d31ae762";
          hash = "sha256-jv9HRIFe1daZs3HjwW1Y6+4P/reDV8r3Yj1Yn7o/WVo=";
        };

        kernelPatches = [
          {
            name = "Asahi config";
            patch = null;
            structuredExtraConfig = with lib.kernel; {
              # Needed for GPU
              ARM64_16K_PAGES = yes;

              ARM64_MEMORY_MODEL_CONTROL = yes;
              ARM64_ACTLR_STATE = yes;

              # Console on M6 uses DockChannel.
              SERIAL_APPLE_DOCKCHANNEL = yes;
              SERIAL_APPLE_DOCKCHANNEL_EARLYCON = yes;

              # Available in the RAM initrd without loading modules.
              ARM_APPLE_SOC_CPUFREQ = yes;

              # The pinned driver uses unexported PCI core helpers.
              PCIE_APPLE = yes;

              # Might lead to the machine rebooting if not loaded soon enough
              APPLE_WATCHDOG = yes;

              # Can not be built as a module, defaults to no
              APPLE_M1_CPU_PMU = yes;

              # Defaults to 'y', but we want to allow the user to set options in modprobe.d
              HID_APPLE = module;

              APPLE_PMGR_MISC = yes;
              APPLE_PMGR_PWRSTATE = yes;

              # Defaults to 'n', but needed to prevent bluetooth stuttering
              BT_BRCMEXT = yes;
            };
            features.rust = true;
          }
        ]
        ++ _kernelPatches;
      } extraArgs
    );

  linux-asahi = callPackage linux-asahi-pkg { };
in
lib.recurseIntoAttrs (linuxPackagesFor linux-asahi)
