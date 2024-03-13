{
  pkgs,
  home-manager,
  username,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

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
    system.stateVersion = "23.11";
    nixpkgs.config.allowUnfree = true;
  };
}
