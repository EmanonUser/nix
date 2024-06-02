{
  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      pane_frames = false;
      default_layout = "compact";
    };
  };

  programs.zsh.initExtra = ''
      if [[ -z "$ZELLIJ" ]]; then
        if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
            # Don't attach to Zellij if SSH connection or if attached to any /dev/tty(x)
            if [[ -n "$SSH_CLIENT" ]] || [[ "$(tty)" =~ ^/dev/tty[0-9]+$ ]]; then
                echo "Skipping Zellij - SSH connection or /dev/tty(x) detected"
            else
                zellij attach -c
            fi
        else
            # Don't start Zellij if SSH connection or if attached to any /dev/tty(x)
            if [[ -n "$SSH_CLIENT" ]] || [[ "$(tty)" =~ ^/dev/tty[0-9]+$ ]]; then
                echo "Skipping Zellij - SSH connection or /dev/tty(x) detected"
            else
                zellij
            fi
        fi

        if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
            exit
        fi
    fi
  '';
}
