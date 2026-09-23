# NixOS / home-manager maintenance targets.
#
#   make help                 list all targets
#   make deploy-zoltraak      build locally + copy closure + switch zoltraak (no OOM)
#   make deploy               build locally + switch every NixOS host
#   make rebuild-zoltraak     sync flake + rebuild + switch zoltraak (on the machine)
#   make home-frieren         rebuild + switch frieren (home-manager only)
#   make install-zoltraak     full reinstall of zoltraak via nixos-anywhere (destructive!)
#   make install-nixos-vm     full reinstall of the incus VM via nixos-anywhere (unencrypted, no LUKS)
#   make install-sasurai-vm   full reinstall of the sasurai test VM via nixos-anywhere (LUKS)
#   make isasurai-vm          deploy the sasurai VM quickly (shortcut)
#   make update               update flake lockfile
#
# Override at the command line, e.g.:
#   make rebuild-sasurai SASURAI_IP=192.168.5.99

SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

USER        ?= emanon
FLAKE       := .

# Hosts with full NixOS deployments.
NIXOS_HOSTS := sasurai zoltraak
# Standalone home-manager hosts (no NixOS system).
HOME_HOSTS  := frieren

ZOLTRAAK_IP ?= 192.168.5.113
SASURAI_IP  ?= sasurai
SASURAI_VM_IP ?= 192.168.122.2
ZOLTRAAK_VM_IP ?= 192.168.122.3

# Tools are run via `nix run` since they aren't installed on this machine.
HOME_MANAGER   := nix run nixpkgs\#home-manager --
ANYWHERE       := nix run github:nix-community/nixos-anywhere --
NIXOS_REBUILD  := nix run nixpkgs\#nixos-rebuild --
AGE            := nix run nixpkgs\#age --

ZOLTRAAK := $(USER)@$(ZOLTRAAK_IP)
SASURAI  := $(USER)@$(SASURAI_IP)
SASURAI_VM  := $(USER)@$(SASURAI_VM_IP)
ZOLTRAAK_VM := $(USER)@$(ZOLTRAAK_VM_IP)

# Temporary file the LUKS passphrase is written to during installs and
# deleted afterwards.
LUKS_KEY ?= /tmp/disk-encryption.key

.PHONY: help install install-zoltraak install-sasurai install-nixos-vm install-sasurai-vm install-zoltraak-vm isasurai-vm \
        deploy deploy-sasurai deploy-zoltraak deploy-sasurai-vm deploy-zoltraak-vm \
        rebuild rebuild-sasurai rebuild-zoltraak rebuild-sasurai-vm rebuild-zoltraak-vm \
        push-sasurai push-zoltraak push-sasurai-vm push-zoltraak-vm \
        home home-frieren \
        print-cert-authority \
        update check fmt

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk 'BEGIN { FS = ":.*?## " } { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }'

# ---------------------------------------------------------------------------
# Full installs via nixos-anywhere (DESTRUCTIVE - reformats the target disk)
# ---------------------------------------------------------------------------

# Canned recipe shared by all install targets: prompts for the SSH user and
# target host (never hardcoded), warns and asks for explicit confirmation,
# then asks for the LUKS passphrase twice (only when $(2) is "luks"), runs
# nixos-anywhere on $(1), and always deletes the key file afterwards (also
# on failure / Ctrl-C).
#
# $(3) is the identity host whose host key is seeded; it defaults to $(1) but
# lets VM variants reuse another host's identity (e.g. sasurai-vm -> sasurai).
#
# The static host key (config/<identity>/ssh/ssh_host_ed25519_key.age) is
# decrypted ONCE here (passphrase prompt) and seeded into the target's
# /persist/etc/ssh via --extra-files, so agenix has its deterministic bootstrap
# identity on the very first boot.
define INSTALL_RECIPE
	@key_host="$(if $(3),$(3),$(1))"; \
	hostkey_age="config/$${key_host}/ssh/ssh_host_ed25519_key.age"; \
	test -f "$$hostkey_age" || { echo "Missing $$hostkey_age - commit a host key for $${key_host} first." >&2; exit 1; }; \
	fs=$$(mktemp -d); \
	trap 'shred -u "$(LUKS_KEY)" 2>/dev/null || rm -f "$(LUKS_KEY)"; rm -rf "$$fs"' EXIT; \
	echo "Seeding $${key_host} host key into persist for agenix bootstrap (passphrase prompt)..."; \
	install -d -m700 "$$fs/persist/etc/ssh"; \
	$(AGE) -d -o "$$fs/persist/etc/ssh/ssh_host_ed25519_key" "$$hostkey_age" \
	  || { echo "Host key decrypt failed." >&2; exit 1; }; \
	chmod 600 "$$fs/persist/etc/ssh/ssh_host_ed25519_key"; \
	cp "config/$${key_host}/ssh/ssh_host_ed25519_key.pub" "$$fs/persist/etc/ssh/"; \
	chmod 644 "$$fs/persist/etc/ssh/ssh_host_ed25519_key.pub"; \
	seed="$$fs"; \
	read -r -p "SSH username: " ssh_user; \
	read -r -p "Target host or IP: " target_host; \
	if [ -z "$$ssh_user" ] || [ -z "$$target_host" ]; then echo "Aborted."; exit 1; fi; \
	echo; \
	echo "WARNING: you are about to DESTRUCTIVELY reinstall $(1) on $${ssh_user}@$${target_host}."; \
	echo "The target disk will be re-partitioned and ALL its data will be lost."; \
	read -r -p "Type YES to confirm, anything else to abort: " confirm; \
	if [ "$$confirm" != "YES" ]; then echo "Aborted."; exit 1; fi; \
	if [ "$(2)" = "luks" ]; then \
	  read -s -p "LUKS passphrase: " key1; echo; \
	  read -s -p "Confirm LUKS passphrase: " key2; echo; \
	  if [ "$$key1" != "$$key2" ]; then echo "LUKS passphrases do not match." >&2; exit 1; fi; \
	  umask 077; printf '%s\n' "$$key1" > "$(LUKS_KEY)"; \
	fi; \
	$(ANYWHERE) --flake $(FLAKE)#$(1) \
	  $(if $(filter luks,$(2)),--disk-encryption-keys /tmp/disk-encryption.key "$(LUKS_KEY)" ,) \
	  $${seed:+--extra-files $$seed} \
	  "$$ssh_user@$$target_host"
endef

install: install-zoltraak install-sasurai ## Full reinstall of every NixOS host (danger!)

install-zoltraak: ## Full reinstall of zoltraak (prompts for user/host, confirmation and LUKS passphrase)
	$(call INSTALL_RECIPE,zoltraak,luks)

install-sasurai: ## Full reinstall of sasurai (prompts for user/host, confirmation and LUKS passphrase)
	$(call INSTALL_RECIPE,sasurai,luks)

install-nixos-vm: ## Full reinstall of the incus VM (unencrypted, no LUKS passphrase; prompts for user/host and confirmation)
	$(call INSTALL_RECIPE,nixos-vm,)

install-sasurai-vm: ## Full reinstall of the sasurai test VM (LUKS; reuses sasurai's identity; prompts for user/host, confirmation and LUKS passphrase)
	$(call INSTALL_RECIPE,sasurai-vm,luks,sasurai)

install-zoltraak-vm: ## Full reinstall of the zoltraak test VM (LUKS; reuses zoltraak's identity; prompts for user/host, confirmation and LUKS passphrase)
	$(call INSTALL_RECIPE,zoltraak-vm,luks,zoltraak)

# Shortcut for the common "just reinstall the sasurai VM" case.
isasurai-vm: install-sasurai-vm ## Shortcut for install-sasurai-vm

# ---------------------------------------------------------------------------
# Local-build deploys: build on THIS machine, copy the closure to the target
# and switch it over SSH. Use this instead of `rebuild-*` when the target is
# low on RAM (zoltraak OOMs building Noctalia/Flutter). Needs `@wheel` in
# nix.settings.trusted-users on the target (see modules/nixos/core/settings.nix)
# to accept the unsigned locally-built paths.
# ---------------------------------------------------------------------------

deploy: deploy-sasurai deploy-zoltraak ## Build locally + switch every NixOS host

deploy-sasurai: ## Build locally, copy to sasurai and switch
	$(NIXOS_REBUILD) switch --flake $(FLAKE)#sasurai --target-host $(SASURAI) --use-remote-sudo

deploy-zoltraak: ## Build locally, copy to zoltraak and switch
	$(NIXOS_REBUILD) switch --flake $(FLAKE)#zoltraak --target-host $(ZOLTRAAK) --use-remote-sudo

deploy-sasurai-vm: ## Build locally, copy to the sasurai VM and switch
	$(NIXOS_REBUILD) switch --flake $(FLAKE)#sasurai-vm --target-host $(SASURAI_VM) --use-remote-sudo

deploy-zoltraak-vm: ## Build locally, copy to the zoltraak VM and switch
	$(NIXOS_REBUILD) switch --flake $(FLAKE)#zoltraak-vm --target-host $(ZOLTRAAK_VM) --use-remote-sudo

# ---------------------------------------------------------------------------
# NixOS rebuild + switch (runs ON the machine itself). The committed flake is
# synced to ~/nix on the target, then `nixos-rebuild switch` is executed there
# via passwordless sudo. Commit your changes first - only `HEAD` is pushed.
# ---------------------------------------------------------------------------

rebuild: rebuild-sasurai rebuild-zoltraak ## Rebuild + switch every NixOS host (on-machine)

push-sasurai: ## Sync the committed flake to sasurai (~/nix)
	@git archive --format=tar.gz HEAD | ssh $(SASURAI) 'rm -rf ~/nix && mkdir -p ~/nix && tar -xzf - -C ~/nix'

push-zoltraak: ## Sync the committed flake to zoltraak (~/nix)
	@git archive --format=tar.gz HEAD | ssh $(ZOLTRAAK) 'rm -rf ~/nix && mkdir -p ~/nix && tar -xzf - -C ~/nix'

rebuild-sasurai: push-sasurai ## Rebuild + switch sasurai on the machine itself
	@ssh $(SASURAI) 'sudo -n nixos-rebuild switch --flake ~/nix#sasurai'

rebuild-zoltraak: push-zoltraak ## Rebuild + switch zoltraak on the machine itself
	@ssh $(ZOLTRAAK) 'sudo -n nixos-rebuild switch --flake ~/nix#zoltraak'

push-sasurai-vm: ## Sync the committed flake to the sasurai VM (~/nix)
	@git archive --format=tar.gz HEAD | ssh $(SASURAI_VM) 'rm -rf ~/nix && mkdir -p ~/nix && tar -xzf - -C ~/nix'

rebuild-sasurai-vm: push-sasurai-vm ## Rebuild + switch the sasurai VM on the machine itself
	@ssh $(SASURAI_VM) 'sudo -n nixos-rebuild switch --flake ~/nix#sasurai-vm'

push-zoltraak-vm: ## Sync the committed flake to the zoltraak VM (~/nix)
	@git archive --format=tar.gz HEAD | ssh $(ZOLTRAAK_VM) 'rm -rf ~/nix && mkdir -p ~/nix && tar -xzf - -C ~/nix'

rebuild-zoltraak-vm: push-zoltraak-vm ## Rebuild + switch the zoltraak VM on the machine itself
	@ssh $(ZOLTRAAK_VM) 'sudo -n nixos-rebuild switch --flake ~/nix#zoltraak-vm'

# ---------------------------------------------------------------------------
# Home-manager rebuilds (standalone hosts only; NixOS hosts are covered by
# the `rebuild-*` targets above via home-manager.nixosModule)
# ---------------------------------------------------------------------------

home: home-frieren ## Rebuild + switch every home-manager-only host

home-frieren: ## Rebuild + switch frieren
	$(HOME_MANAGER) switch --flake $(FLAKE)#frieren

# ---------------------------------------------------------------------------
# Host CA (client-side known_hosts entry)
# ---------------------------------------------------------------------------

print-cert-authority: ## Print the @cert-authority line clients need in ~/.ssh/known_hosts
	@echo "@cert-authority \"*.home.arpa,*.emanon.dev\" $$(cut -d' ' -f1,2 modules/ssh/host_ca.pub)"

# ---------------------------------------------------------------------------
# Flake maintenance
# ---------------------------------------------------------------------------

update: ## Update every flake input
	nix flake update

check: ## Evaluate all configurations
	nix flake check

fmt: ## Format flake with alejandra
	nix run nixpkgs#alejandra -- .