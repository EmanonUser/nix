{lib, ...}: {
  programs.alacritty = {
    enable = true;

    settings = {
      window.opacity = lib.mkForce 1.0;
    };
  };
}
