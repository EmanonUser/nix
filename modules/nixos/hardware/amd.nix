{pkgs, ...}: {
  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
    libGL
  ];

  hardware.graphics.extraPackages32 = with pkgs; [
    # For 32 bit applications
    driversi686Linux.amdvlk
  ];

  services.xserver.videoDrivers = ["amdgpu"];
  hardware.graphics.enable32Bit = true; # For 32 bit applications
}
