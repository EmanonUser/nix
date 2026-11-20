{
  config,
  pkgs,
  lib,
  ...
}: let
  writeAuth = pkgs.writeShellScript "opencode-write-auth" ''
    set -euo pipefail
    umask 077
    key=$(${pkgs.coreutils}/bin/cat /run/agenix/opencode-api-key)
    dir="$HOME/.local/share/opencode"
    auth="$dir/auth.json"
    ${pkgs.coreutils}/bin/mkdir -p "$dir"
    tmp=$(${pkgs.coreutils}/bin/mktemp "$dir/auth.json.XXXXXX")
    trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT
    if [ -s "$auth" ] && ${pkgs.jq}/bin/jq -e 'type == "object"' "$auth" >/dev/null 2>&1; then
      ${pkgs.jq}/bin/jq --arg key "$key" '."opencode-go" = {type: "api", key: $key}' "$auth" >"$tmp"
    else
      ${pkgs.jq}/bin/jq -n --arg key "$key" '{"opencode-go": {type: "api", key: $key}}' >"$tmp"
    fi
    ${pkgs.coreutils}/bin/mv "$tmp" "$auth"
    ${pkgs.coreutils}/bin/chmod 600 "$auth"
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

  home.activation.atuin-opencode-hook = lib.mkIf atuinEnabled (lib.hm.dag.entryAfter ["writeBoundary"] ''
    (
      export PATH=${lib.makeBinPath [pkgs.opencode]}:$PATH
      run ${lib.getExe config.programs.atuin.package} hook install opencode >/dev/null 2>&1 || true
    )
  '');

  home.activation.opencode-auth = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -r /run/agenix/opencode-api-key ]; then
      run ${writeAuth}
    fi
  '';

  systemd.user.services.opencode-auth = {
    Unit = {
      Description = "Seed opencode API credentials from agenix";
      ConditionPathExists = ["/run/agenix/opencode-api-key"];
    };
    Service = {
      Type = "oneshot";
      Environment = ["HOME=${config.home.homeDirectory}"];
      ExecStart = "${writeAuth}";
    };
    Install.WantedBy = ["default.target"];
  };
}
