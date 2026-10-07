{
  noctalia,
  ...
}: {
  imports = [noctalia.nixosModules.default];

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  services.gnome.gcr-ssh-agent.enable = false;
}
