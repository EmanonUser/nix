{username, ...}: {
  users.users.${username} = {
    extraGroups = ["libvirtd"];
  };
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
