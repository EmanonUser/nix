# NixOS / home-manager maintenance targets.
#
#   make help                 list all targets
#   make rebuild-zoltraak     sync flake + rebuild + switch zoltraak (on the machine)
#   make rebuild              rebuild + switch every NixOS host (on-machine)
#   make home-frieren         rebuild + switch frieren (home-manager only)
#   make install-zoltraak     full reinstall of zoltraak via nixos-anywhere (destructive!)
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

# Tools are run via `nix run` since they aren't installed on this machine.
HOME_MANAGER := nix run nixpkgs\#home-manager --
ANYWHERE     := nix run github:nix-community/nixos-anywhere --

ZOLTRAAK := $(USER)@$(ZOLTRAAK_IP)
SASURAI  := $(USER)@$(SASURAI_IP)

# Temporary file the LUKS passphrase is written to during installs and
# deleted afterwards.
LUKS_KEY ?= /tmp/disk-encryption.key

.PHONY: help install install-zoltraak install-sasurai \
        rebuild rebuild-sasurai rebuild-zoltraak \
        push-sasurai push-zoltraak \
        home home-frieren \
        sign-host-certs print-cert-authority \
        update check fmt

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk 'BEGIN { FS = ":.*?## " } { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }'

# ---------------------------------------------------------------------------
# Full installs via nixos-anywhere (DESTRUCTIVE - reformats the target disk)
# ---------------------------------------------------------------------------

# Canned recipe shared by all install targets: prompts for the SSH user and
# target host (never hardcoded), warns and asks for explicit confirmation,
# then asks for the LUKS passphrase twice, runs nixos-anywhere on $(1), and
# always deletes the key file afterwards (also on failure / Ctrl-C).
define INSTALL_RECIPE
	@trap 'shred -u "$(LUKS_KEY)" 2>/dev/null || rm -f "$(LUKS_KEY)"' EXIT; \
	read -r -p "SSH username: " ssh_user; \
	read -r -p "Target host or IP: " target_host; \
	if [ -z "$$ssh_user" ] || [ -z "$$target_host" ]; then echo "Aborted."; exit 1; fi; \
	echo; \
	echo "WARNING: you are about to DESTRUCTIVELY reinstall $(1) on $${ssh_user}@$${target_host}."; \
	echo "The target disk will be re-partitioned and ALL its data will be lost."; \
	read -r -p "Type YES to confirm, anything else to abort: " confirm; \
	if [ "$$confirm" != "YES" ]; then echo "Aborted."; exit 1; fi; \
	read -s -p "LUKS passphrase: " key1; echo; \
	read -s -p "Confirm LUKS passphrase: " key2; echo; \
	if [ "$$key1" != "$$key2" ]; then echo "LUKS passphrases do not match." >&2; exit 1; fi; \
	umask 077; printf '%s\n' "$$key1" > "$(LUKS_KEY)"; \
	$(ANYWHERE) --flake $(FLAKE)#$(1) \
	  --disk-encryption-keys /tmp/disk-encryption.key "$(LUKS_KEY)" \
	  "$$ssh_user@$$target_host"
endef

install: install-zoltraak install-sasurai ## Full reinstall of every NixOS host (danger!)

install-zoltraak: ## Full reinstall of zoltraak (prompts for user/host, confirmation and LUKS passphrase)
	$(call INSTALL_RECIPE,zoltraak)

install-sasurai: ## Full reinstall of sasurai (prompts for user/host, confirmation and LUKS passphrase)
	$(call INSTALL_RECIPE,sasurai)

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

# ---------------------------------------------------------------------------
# Home-manager rebuilds (standalone hosts only; NixOS hosts are covered by
# the `rebuild-*` targets above via home-manager.nixosModule)
# ---------------------------------------------------------------------------

home: home-frieren ## Rebuild + switch every home-manager-only host

home-frieren: ## Rebuild + switch frieren
	$(HOME_MANAGER) switch --flake $(FLAKE)#frieren

# ---------------------------------------------------------------------------
# SSH host certificates (static per-host keys live in config/<host>/ssh/)
# ---------------------------------------------------------------------------

# Private key of the Host CA (distinct from the user CA).
HOST_CA_KEY ?= $(HOME)/.ssh/emanon_host_ca

# per-host cert principals: the names/IPs clients use to reach each host
HOST_PRINCIPALS := zoltraak:zoltraak,192.168.5.113 sasurai:sasurai,sasurai.home.arpa

sign-host-certs: ## Re-sign all host certificates with the Host CA (HOST_CA_KEY=...)
	@test -f $(HOST_CA_KEY) || { echo "Host CA key not found: $(HOST_CA_KEY)"; exit 1; }
	@for hp in $(HOST_PRINCIPALS); do \
	  h=$${hp%%:*}; p=$${hp#*:}; \
	  ssh-keygen -s $(HOST_CA_KEY) -I "$$h host cert" -h -n "$$p" \
	    config/$$h/ssh/ssh_host_ed25519_key.pub; \
	done
	@ssh-keygen -y -f $(HOST_CA_KEY) | { read t k; echo "$$t $$k noctalia host CA"; } > modules/ssh/host_ca.pub
	@echo "Re-signed host certs for: $(NIXOS_HOSTS)"; \
	echo "Host CA public key written to modules/ssh/host_ca.pub:"; \
	echo "  $$(cut -d' ' -f1,2 modules/ssh/host_ca.pub)"

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