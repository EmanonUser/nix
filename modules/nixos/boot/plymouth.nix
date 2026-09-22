# Theme and initrd GPU driver are set per host in config/<host>/nixos.nix:
#   sasurai  : "spinner" (amdgpu loaded in the initrd)
#   zoltraak : "text"    (old NVIDIA driver can't drive a splash from the initrd)
{...}: {
  boot.plymouth = {
    enable = true;
  };
}