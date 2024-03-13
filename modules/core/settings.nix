{
  pkgs,
  home-manager,
  username,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.11";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    warn-dirty = false;
  };

  home-manager.users.${username} = {
    programs.home-manager.enable = true;
    home.username = "emanon";
    home.homeDirectory = "/home/emanon";
    home.stateVersion = "23.11";
    nixpkgs.config.allowUnfree = true;
  };
}
