{pkgs, ...}: {
  # CachyOS-like desktop/gaming tuning.
  #
  # Mirrors CachyOS's `cachyos-settings` package (sysctls, zram, blacklists):
  #   https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/sysctl.d/70-cachyos-settings.conf
  #
  # The `linux-cachyos` kernel itself is not available in nixpkgs (removed),
  # and `linuxPackages_zen` is older than the stock kernel on this host, so we
  # keep the default kernel and apply the userspace-side optimisations only.

  # CPU: always run at full speed, like CachyOS's `game-performance` profile.
  powerManagement.cpuFreqGovernor = "performance";

  # CachyOS sysctl set (70-cachyos-settings.conf).
  boot.kernel.sysctl = {
    # With zram as swap, prefer swap over dropping page cache.
    "vm.swappiness" = 100;
    # Keep VFS/dir/inode caches around longer.
    "vm.vfs_cache_pressure" = 50;
    # Start writing out dirty data at 64 MiB, hit the write limit at 256 MiB.
    "vm.dirty_background_bytes" = 67108864;
    "vm.dirty_bytes" = 268435456;
    # Only flush dirty pages once every 15s.
    "vm.dirty_writeback_centisecs" = 1500;
    # zram-backed swap: disable swap read-ahead (no locality benefit there).
    "vm.page-cluster" = 0;
    # Disable the NMI watchdog (saves a timer tick, lowers latency spikes).
    "kernel.nmi_watchdog" = 0;
    # Keep kernel messages off the console.
    "kernel.printk" = "3 3 3 3";
    "kernel.unprivileged_userns_clone" = 1;
    "kernel.kptr_restrict" = 2;
    # Larger receive queue, may help avoid packet loss.
    "net.core.netdev_max_backlog" = 4096;
    "fs.file-max" = 2097152;
  };

  # zram swap with zstd, the CachyOS default (half of RAM).
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Don't load TCO watchdog modules (required for Ryzen).
  boot.blacklistedKernelModules = ["iTCO_wdt" "sp5100_tco"];
}
