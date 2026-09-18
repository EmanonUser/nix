{username, ...}: {
  # Host keys are persisted via impermanence; make agenix decrypt from the
  # persistent copies so secrets survive reboots.
  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
    "/persist/etc/ssh/ssh_host_rsa_key"
  ];
}
