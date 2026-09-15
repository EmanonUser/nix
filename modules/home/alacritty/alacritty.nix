{
  lib,
  ...
}: {
  # alacritty is auto-installed by programs.alacritty.enable below.
  programs.alacritty = {
    enable = true;

    settings = {
      window.opacity = lib.mkForce 1.0;
    };
  };
}
