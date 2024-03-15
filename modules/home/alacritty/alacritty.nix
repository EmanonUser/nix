{pkgs, ...}: {
  home.packages = with pkgs; [
    alacritty
  ];

  programs.alacritty = {
    enable = true;

    settings = {
      window.opacity = 0.5;
    };
  };
}
