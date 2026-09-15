{pkgs, ...}: {
  # starship is auto-installed by programs.starship.enable below.
  programs.starship = {
    enable = true;
  };
}
