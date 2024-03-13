{pkgs, ...}: {
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    libGL
  ];

  hardware.opengl.extraPackages32 = with pkgs; [
    # For 32 bit applications
    driversi686Linux.amdvlk
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true; # For 32 bit applications
}
