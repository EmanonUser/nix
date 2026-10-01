{pkgs, ...}: {
  # No home.file.".config/nvim": the neovim package is built by
  # nix-wrapper-modules (modules/neovim/wrapper.nix) with the lua tree as its
  # in-store config_directory, so nothing lands in ~/.config/nvim. `neovim`
  # here is the wrapped package, via the overlay in flake.nix. The language
  # servers are on that wrapper's PATH via its runtimePkgs.
  home.packages = with pkgs; [
    neovim

    # runtime deps used by plugins (kept system-wide: useful outside neovim too)
    git
    ripgrep
    fd
    jq
    gnumake
    clang
    tree-sitter
  ];
}
