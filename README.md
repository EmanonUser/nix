# nix

Personal [NixOS](https://nixos.org) + [Home Manager](https://github.com/nix-community/home-manager)
configuration, managed as a single flake.

One flake builds several machines: full NixOS desktops, throwaway VM twins used
for testing, and standalone Home Manager profiles. Hardware/disk definitions,
per-machine choices and reusable modules are kept in separate layers so a host
config reads as a short, explicit list of imports.

## What it does

- **Declarative desktops** — Plasma (Wayland), niri and Noctalia shells, all
  themed from one wallpaper via [Stylix](https://github.com/danth/stylix).
- **Impermanence** — `/` is a tmpfs; only an explicit allowlist of paths
  (under `/persist`) survives a reboot, via
  [impermanence](https://github.com/nix-community/impermanence).
- **Encrypted, per-host secrets** — [agenix](https://github.com/ryantm/agenix)
  seals the user password, SSH identity and host key to each host's own
  ed25519 key, so a leaked ciphertext from one machine unlocks nothing else.
- **No password login** — `openssh` with `TrustedUserCAKeys`, host
  certificates, and an immutable user whose password comes from an age secret.
- **Encrypted root** — LUKS with a FIDO2 token fallback at boot, ZFS or
  btrfs on top, declared with [disko](https://github.com/nix-community/disko).
- **Test before you ship** — every bare-metal host has a `*-vm` twin: the same
  config, evaluated with `vm = true`, running in a throwaway Incus VM.
- **Tooling** — Neovim (LSP + lazy plugins, native markdown preview via snacks),
  zsh + starship/atuin/zoxide, Ghostty, niri, zellij, direnv, grabit,
  PipeWire/RnNoise.
- **Make-driven operations** — the `Makefile` is the supported entry point for
  installing, deploying, rebuilding and formatting.

## Hosts

| Flake output | Where it runs | Role |
| --- | --- | --- |
| `sasurai` | bare metal | Plasma/niri desktop, ZFS on LUKS |
| `zoltraak` | bare metal | Noctalia/niri desktop, btrfs on LUKS |
| `sasurai-vm` | Incus VM | throwaway twin of `sasurai` (`vm = true`) |
| `zoltraak-vm` | Incus VM | throwaway twin of `zoltraak` (`vm = true`) |
| `nixos-vm` | Incus VM | **headless dev environment** — SSH in, edit, build |
| `nixos-tests` | Incus VM | **headless smoke-test box** — `vm = true`, `vmtest` password |
| `fern` | workstation | standalone Home Manager profile |

The two `nixos-*` hosts are the ones you drive day to day. `nixos-vm` carries
the toolchains (gcc/clang, cmake, ninja, go, rustup, python, nodejs, gdb,
valgrind, nix tooling) in `configs/nixos-vm/nix-packages`, and reuses fern's
home profile. `nixos-tests` stays deliberately lean — no desktop, no
toolchains, barely a home profile — because its only job is to answer "does
this config activate?", which keeps the smoke test fast. The twins
(`sasurai-vm`, `zoltraak-vm`) are separate: they run the *real* desktop
config, so they catch DE regressions that a headless box cannot.

## Repository layout

```
flake.nix              # inputs + nixosConfigurations / homeConfigurations
flake.lock             # pinned inputs
Makefile               # install / deploy / rebuild / home / update targets
README.md              # this file
hosts/                 # LAYER 1 — what this *machine* is
  <host>/<host>.nix             # entry point pulled in by the flake
  <host>/hardware-configuration.nix
  <host>/disko.nix             # disks, LUKS, filesystems, pools
  vm/common.nix                # adaptations shared by every *-vm twin
  vm/disko.nix                 # virtio disk layout shared by the Incus VMs
  localization.nix             # timezone, locale, keyboard (shared)
configs/                # LAYER 2 — what this host *runs*
  <host>/nixos.nix             # host's module list + home-manager wiring
  <host>/home.nix              # which home-manager modules it imports
  <host>/home-packages/        # per-user GUI/dev packages
  <host>/nix-packages/         # per-host system packages
  <host>/agenix.nix            # host-specific secret declarations (standalone HM)
  <host>/ssh/                  # per-host key material (.age + public halves)
modules/               # LAYER 3 — reusable, host-agnostic modules
  nixos/…                     # system-level modules (core, boot, hardware, DE…)
  settings/…                  # cross-cutting home-manager settings
  zsh, neovim, ssh, git, …    # user-level modules
  */config, */*.kdl, */*.lua   # static config shipped by the module above it
users/                 # user accounts (parameterised by `username`)
  <user>/<user>.nix            # account, groups, sudo
  <user>/password.age          # shared password hash (sealed to all host keys)
  <user>/home-assistant.age    # shared Home Assistant token (sealed to all host keys)
```

### The layering logic

Three layers, evaluated in this order, each with a single responsibility:

| Layer | Question it answers | Contains | Never contains |
| --- | --- | --- | --- |
| `hosts/<name>` | *Which physical/virtual machine is this?* | hardware, disks, import entry point, VM overrides | user choices, package lists |
| `configs/<name>` | *What does this machine do?* | module imports, DE, services, package lists, home-manager wiring | machine-specific hardware |
| `modules/` | *How is a capability implemented?* | one concern per file, reusable by any host | host names, disk layouts |

`flake.nix` only names a host and a few flags; it never lists modules itself.
Its `mkSystem` passes `hostname`, `username`, `system`, `vm`, `luks`,
`filesystem` and `netHostName` through `specialArgs`, so a module can branch on
`vm` (e.g. skip Secure Boot, amdgpu, incus/podman in a test VM) without
duplicating the host config.

`users/` sits beside the three: it is parameterised on the `username` special
arg, so adding a user means adding a directory, not editing every host.

### How NixOS and Home Manager fit together

- NixOS hosts declare `home-manager.users.${username}` in their
  `configs/<host>/nixos.nix`, importing `configs/<host>/home.nix` with
  `useGlobalPkgs = true`. One `nixos-rebuild` therefore updates system *and*
  user environment.
- The standalone Home Manager host is declared as a
  `homeConfigurations.<name>` in the flake, importing `configs/<name>/home.nix`
  directly — the same file layout, without a NixOS system around it.
- `configs/<host>/home.nix` is always just a list of `modules/*` imports plus
  `home-packages`; the two are interchangeable between the two models.

### Modules at a glance

System (`modules/nixos/`): `core` (settings, fonts, agenix, impermanence),
`boot` (bootloader, plymouth, memtest86+, secureboot/lanzaboote),
`hardware` (amd, network, pipewire), DEs (`kde`, `niri`, `noctalia`, `cosmic`),
`ssh-server`, `samba-client` (fern NAS cifs automount), `services`, `steam`,
`gaming`, `virtualisation` (incus, podman), `greetd`, `stylix`.

User (`modules/`): `zsh`, `starship`, `atuin`, `zoxide`, `direnv`, `neovim`,
`ghostty`, `alacritty`, `niri`, `zellij`, `ssh`, `git`, `grabit`, `rnnoise`,
`settings`.

## Cross-cutting decisions

- **Impermanence** — tmpfs `/`, persistence allowlist in
  `modules/nixos/core/impermanence.nix`, plus per-host additions.
- **Bootstrap identity** — each host's ed25519 host key is committed encrypted;
  the installer decrypts it once and seeds it into `/persist/etc/ssh`, so
  agenix can decrypt everything on the very first boot.
- **VM twins** — `sasurai-vm`, `zoltraak-vm` reuse the *same* host config with
  `vm = true` plus `hosts/vm/common.nix`; they skip bare-metal-only modules,
  get virtio storage, a serial console, a bundled wallpaper and a throwaway
  password. `nixos-tests` reuses that same `vm = true` machinery as a
  standalone host, so it also gets the throwaway password and skips the shared
  `password.age` — which is why it carries its own key material under
  `configs/nixos-tests/ssh/` and needs no passphrase to install.
- **Secrets hygiene** — `.gitignore` is an allowlist (ignore everything, then
  re-include `*.nix`, `*.age`, `*.pub`, …), so a new file can never be
  committed by accident.
- **Secrets never enter git in the clear** — only `.age` ciphertext, public keys
  and certificates are versioned.

## Workflow

```sh
make help            # every target, with descriptions
make deploy          # build here, copy the closure, switch each NixOS host
make rebuild         # rebuild on the machine itself (flake synced via git archive)
make home            # home-manager-only hosts
make install-<host>  # destructive reinstall via nixos-anywhere (LUKS, seeds host key)
make update          # nix flake update
make check           # nix flake check
make fmt             # alejandra
```

`Makefile` variables (`SASURAI_IP`, `ZOLTRAAK_IP`, …) can be overridden per
invocation: `make rebuild-sasurai SASURAI_IP=192.168.5.99`.

## Import chain: `flake.nix` → deepest file

There is no literal "last evaluated file" (Nix evaluates the module system as
a fixed point), but the import graph has a clear shape. Every configuration
terminates in the same place.

```
flake.nix
└── hosts/<host>                              (mkSystem, specialArgs)
    ├── hosts/localization.nix
    ├── hosts/<host>/hardware-configuration.nix        [bare metal only]
    ├── users/<user>/<user>.nix
    └── configs/<host>/nixos.nix
        ├── modules/nixos/core/settings.nix
        ├── modules/nixos/core/fonts.nix
        ├── modules/nixos/core/agenix.nix
        ├── modules/nixos/boot/bootloader.nix
        ├── modules/nixos/core/impermanence.nix
        ├── modules/nixos/boot/plymouth.nix
        ├── modules/nixos/boot/memtest86.nix
        ├── hosts/<host>/disko.nix
        ├── modules/nixos/services/services.nix
        ├── modules/nixos/ssh-server/ssh-server.nix
        ├── modules/nixos/hardware/{pipewire,network}.nix
        ├── modules/nixos/<desktop>/…                 (kde | niri | noctalia)
        ├── modules/nixos/steam/steam.nix
        ├── modules/nixos/gaming/gaming.nix
        ├── modules/nixos/stylix/stylix.nix
        ├── modules/nixos/niri/niri.nix
        ├── configs/<host>/nix-packages/nix-packages.nix
        ├── …                        (if !vm: secureboot, amd, virtualisation)
        └── configs/<host>/home.nix
            ├── configs/<host>/home-packages/home-packages.nix
            ├── modules/atuin, direnv, ghostty, git, grabit, neovim,
            │   niri, rnnoise, settings, ssh, starship, zellij, zoxide
            └── modules/zsh/zsh.nix          ← terminal Nix module
                └── modules/zsh/git_auto_fetch.zsh   ← deepest file in the graph
```

So the full path of the last file reached, for every host, is:

```
modules/zsh/git_auto_fetch.zsh
```

reached as
`flake.nix` → `hosts/<host>/<host>.nix` → `configs/<host>/nixos.nix` →
`configs/<host>/home.nix` → `modules/zsh/zsh.nix` (zsh.nix:72) →
`modules/zsh/git_auto_fetch.zsh`.
