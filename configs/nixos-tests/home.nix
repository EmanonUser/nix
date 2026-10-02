{
  # Deliberately minimal: this box exists to activate a system config, and the
  # flake reaches it through `make rebuild-nixos-tests` (git archive + switch),
  # so there is nothing to edit here. Editing and building happen on nixos-vm.
  #
  # modules/ssh/ssh.nix is skipped on purpose: it ships the host's roaming user
  # certificate, which only the CA can sign, and a throwaway identity has none.
  imports = [
    ../../modules/opencode/opencode.nix
    ../../modules/settings/home-manager-settings.nix
    ../../modules/starship/starship.nix
    ../../modules/zoxide/zoxide.nix
    ../../modules/zsh/zsh.nix
  ];
}
