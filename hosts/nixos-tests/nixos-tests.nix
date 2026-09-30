# Second throwaway Incus VM, smoke-testing config changes before they reach
# sasurai or zoltraak. Built with vm = true, so hosts/vm/common.nix supplies
# the virtio disk, serial console, incus agent and the throwaway "vmtest"
# credentials; everything below is only what the machine's *identity* needs.
{username, ...}: {
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    ../localization.nix
    ../../users/${username}/${username}.nix
    ../../configs/nixos-tests/nixos.nix
  ];
}
