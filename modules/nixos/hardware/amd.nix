{pkgs, ...}: {
  hardware.graphics.extraPackages = with pkgs; [
    libGL
  ];

  services.xserver.videoDrivers = ["amdgpu"];
  hardware.graphics.enable32Bit = true;
}
