{pkgs, ...}: {
  # CachyOS-like desktop/gaming tuning.
  #
  # Mirrors CachyOS's `cachyos-settings` package (sysctls, zram, blacklists):
  #   https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/sysctl.d/70-cachyos-settings.conf
  powerManagement.cpuFreqGovernor = "performance";

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_background_bytes" = 67108864;
    "vm.dirty_bytes" = 268435456;
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.page-cluster" = 0;
    "kernel.nmi_watchdog" = 0;
    "kernel.printk" = "3 3 3 3";
    "kernel.unprivileged_userns_clone" = 1;
    "kernel.kptr_restrict" = 2;
    "net.core.netdev_max_backlog" = 4096;
    "fs.file-max" = 2097152;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.blacklistedKernelModules = ["iTCO_wdt" "sp5100_tco"];
}
