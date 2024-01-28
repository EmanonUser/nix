{
  config,
  pkgs,
  ...
}: {
  home.username = "emanon";
  home.homeDirectory = "/home/emanon";

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      ls = "ls --color";
      ll = "ls --color --group-directories-first -lh";
      la = "ls --color --group-directories-first -Alh --ignore='[^.]*'";
      ip = "ip --color=auto";
      grep = "grep --color";
    };
  };

  programs.starship.enable = true;
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = ["--disable-up-arrow"];
  };

  programs.git = {
    enable = true;
    userName = "Emanon";
    userEmail = "moemanon@pm.me";
    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };

  programs.alacritty = {
    enable = true;
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    alacritty
    starship
    htop
  ];

  home.file = {
    ".ssh/allowed_signers".text = "* ${builtins.readFile /home/emanon/.ssh/id_ed25519.pub}";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind = [
      "$mod, a, exec, alacritty"

      "$mod, ampersand, workspace, 1"
      "$mod SHIFT, ampersand, movetoworkspace, 1"
      "$mod, eacute, workspace, 2"
      "$mod SHIFT, eacute, movetoworkspace, 2"
      "$mod, quotedbl, workspace, 3"
      "$mod SHIFT, quotedbl, movetoworkspace, 3"
      "$mod, apostrophe, workspace, 4"
      "$mod SHIFT, apostrophe, movetoworkspace, 4"
      "$mod, parenleft, workspace, 5"
      "$mod SHIFT, parenleft, movetoworkspace, 5"
      "$mod, egrave, workspace, 6"
      "$mod SHIFT, egrave, movetoworkspace, 6"
      "$mod, minus, workspace, 7"
      "$mod SHIFT, minus, movetoworkspace, 7"
      "$mod, underscore, workspace, 8"
      "$mod SHIFT, underscore, movetoworkspace, 8"
      "$mod, ccedilla, workspace, 9"
      "$mod SHIFT, underscore, movetoworkspace, 9"
      "$mod, agrave, workspace, 10"
      "$mod SHIFT, agrave, movetoworkspace, 10"
    ];

    input = {
      kb_layout = "fr";
      kb_variant = "";
      follow_mouse = 1;
      sensitivity = 0;
    };
  };
}
