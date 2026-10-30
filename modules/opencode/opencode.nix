{
  config,
  pkgs,
  lib,
  ...
}: let
  writeAuth = pkgs.writeShellScript "opencode-write-auth" ''
    set -euo pipefail
    umask 077
    key=$(cat /run/agenix/opencode-api-key)
    mkdir -p "$HOME/.local/share/opencode"
    printf '{"opencode-go":{"type":"api","key":"%s"}}\n' "$key" >"$HOME/.local/share/opencode/auth.json"
    chmod 600 "$HOME/.local/share/opencode/auth.json"
  '';

  atuinEnabled = config.programs.atuin.enable or false;

  opencodeConfig =
    {
      "$schema" = "https://opencode.ai/config.json";
    }
    // lib.optionalAttrs atuinEnabled {
      mcp.atuin = {
        type = "local";
        command = [(lib.getExe config.programs.atuin.package) "mcp"];
        enabled = true;
      };
    };
in {
  home.packages = [pkgs.opencode];

  xdg.configFile."opencode/opencode.jsonc" = {
    force = true;
    text = builtins.toJSON opencodeConfig + "\n";
  };

  home.activation.opencode-auth = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -r /run/agenix/opencode-api-key ]; then
      run ${writeAuth}
    fi
  '';
}
