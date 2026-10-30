{
  config,
  pkgs,
  ...
}: let
  ageSecrets = config.age.secrets or {};
  hmSecrets = (ageSecrets ? "atuin-key") && (ageSecrets ? "atuin-token");
  keyPath =
    if hmSecrets
    then ageSecrets."atuin-key".path
    else "/run/agenix/atuin-key";
  tokenPath =
    if hmSecrets
    then ageSecrets."atuin-token".path
    else "/run/agenix/atuin-token";
  keyCondition =
    if hmSecrets
    then "%t/agenix/atuin-key"
    else "/run/agenix/atuin-key";
  tokenCondition =
    if hmSecrets
    then "%t/agenix/atuin-token"
    else "/run/agenix/atuin-token";
in {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = ["--disable-up-arrow"];
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      keymap_mode = "vim-normal";
      search_mode = "daemon-fuzzy";
      daemon = {
        enabled = true;
        autostart = true;
      };
      threads = {
        capture = true;
        capture_tools = true;
      };
      output = {
        enabled = true;
      };
      pty_proxy = {
        enabled = true;
      };
    };
  };

  systemd.user.services.atuin-token = {
    Unit = {
      Description = "Seed the Atuin sync session token";
      Before = ["atuin-daemon.service"];
      After = ["agenix.service"];
      ConditionPathExists = [keyCondition tokenCondition];
    };
    Install.WantedBy = ["default.target"];
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "atuin-token" ''
        set -euo pipefail

        data_dir="$HOME/.local/share/atuin"
        ${pkgs.coreutils}/bin/install -d -m 0700 "$data_dir"
        ${pkgs.coreutils}/bin/install -m 0600 "${keyPath}" "$data_dir/key"

        token="$(< "${tokenPath}")"
        if [ -z "$token" ]; then
          echo "atuin-token secret is empty" >&2
          exit 1
        fi
        hex="$(printf '%s' "$token" | ${pkgs.coreutils}/bin/od -An -tx1 | ${pkgs.coreutils}/bin/tr -d '[:space:]')"

        ${pkgs.sqlite}/bin/sqlite3 "$data_dir/meta.db" <<SQL
        CREATE TABLE IF NOT EXISTS meta (
            key text NOT NULL PRIMARY KEY,
            value text NOT NULL,
            updated_at integer NOT NULL DEFAULT (strftime('%s', 'now'))
        );
        INSERT INTO meta (key, value, updated_at)
        VALUES ('hub_session', CAST(X'$hex' AS TEXT), strftime('%s', 'now'))
        ON CONFLICT(key) DO UPDATE SET
            value = excluded.value,
            updated_at = excluded.updated_at;
        DELETE FROM meta WHERE key = 'session';
        SQL
      '';
    };
  };
}
