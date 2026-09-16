{username, ...}: {
  # Host keys are persisted via impermanence; make agenix decrypt from the
  # persistent copies so secrets survive reboots.
  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
    "/persist/etc/ssh/ssh_host_rsa_key"
  ];

  age.secrets = {
    atuin_session = {
      file = ../../../secrets/atuin_session.age;
      owner = username;
      group = "users";
      mode = "600";
    };
    atuin_key = {
      file = ../../../secrets/atuin_key.age;
      owner = username;
      group = "users";
      mode = "600";
    };
  };
}
