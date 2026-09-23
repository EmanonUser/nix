{
  lib,
  pkgs,
  username,
  hostname,
  vm ? false,
  ...
}: {
  # Host keys are persisted via impermanence; make agenix decrypt from the
  # persistent copies so secrets survive reboots. The ed25519 key doubles as
  # the deterministic bootstrap identity (seeded at first install), which is
  # why it is the only identity age may use here.
  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
  ];

  # This host's user SSH identity, sealed to its own host key
  # (config/${hostname}/ssh/ssh_host_ed25519_key.age).
  # Written to /persist directly so it survives the initrd activation (agenix
  # runs before impermanence bind-mounts /persist/home/<user> onto /home/<user>).
  # A real file (symlink = false), so sshd/git never see a dangling /run/agenix
  # link during early boot.
  age.secrets."user-ssh-id" = {
    file = ../../../config + "/${hostname}/ssh/id_ed25519.age";
    path = "/persist/home/${username}/.ssh/id_ed25519";
    owner = username;
    mode = "0600";
    symlink = false;
  };

  age.secrets."user-password" = lib.mkIf (!vm) {
    # User password hash, shared across NixOS hosts (users/<user>/password.age),
    # encrypted to every host's ed25519 key. Skips the throwaway *-vm twins:
    # their freshly generated host key can't decrypt it (they use "vmtest").
    file = ../../../users + "/${username}/password.age";
  };

  # agenix's activation script mkdirs ~/.ssh as root (0755) before any systemd
  # unit runs; home-manager - which runs as the user - then needs to write
  # .ssh/config and the pub keys into it. Hand the directory (and the home dir
  # itself, if agenix raced impermanence on first boot) to the user on every
  # boot; on boot, activation has already completed, so by multi-user.target the
  # directories exist and only ownership/mode need fixing.
  systemd.services."agenix-fix-ssh-dir" = {
    description = "Give the user ownership of ~/.ssh and ~ before home-manager";
    wantedBy = ["multi-user.target"];
    before = ["home-manager-${username}.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "agenix-fix-ssh-dir" ''
        ${pkgs.coreutils}/bin/install -d -o ${username} -g users -m 0755 /home/${username}
        ${pkgs.coreutils}/bin/install -d -o ${username} -g users -m 0700 /home/${username}/.ssh
        ${pkgs.coreutils}/bin/chown ${username}:users /home/${username}
        ${pkgs.coreutils}/bin/chmod 0755 /home/${username}
        ${pkgs.coreutils}/bin/chown ${username}:users /home/${username}/.ssh
        ${pkgs.coreutils}/bin/chmod 0700 /home/${username}/.ssh
      '';
      RemainAfterExit = true;
    };
  };
}
