{
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    warn-dirty = false;
  };
}
