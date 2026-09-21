# NixOS / home-manager maintenance targets.
#
#   make help                 list all targets
#   make deploy-zoltraak      build locally + copy closure + switch zoltraak (no OOM)
#   make deploy               build locally + switch every NixOS host
#   make rebuild-zoltraak     sync flake + rebuild + switch zoltraak (on the machine)
#   make home-frieren         rebuild + switch frieren (home-manager only)
#   make install-zoltraak     full reinstall of zoltraak via nixos-anywhere (destructive!)
#   make install-nixos-vm     full reinstall of the incus VM via nixos-anywhere (no LUKS)
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
HOME_MANAGER   := nix run nixpkgs\#home-manager --
ANYWHERE       := nix run github:nix-community/nixos-anywhere --
NIXOS_REBUILD  := nix run nixpkgs\#nixos-rebuild --
AGE            := nix run nixpkgs\#age --

ZOLTRAAK := $(USER)@$(ZOLTRAAK_IP)
SASURAI  := $(USER)@$(SASURAI_IP)

# Temporary file the LUKS passphrase is written to during installs and
# deleted afterwards.
LUKS_KEY ?= /tmp/disk-encryption.key

# Every host that keeps a per-host SSH host key in config/<host>/ssh/. These
# are the deterministic keys agenix bootstraps from (the single non-agenix
# secret), so they must be captured for every host.
HOST_KEY_HOSTS := $(NIXOS_HOSTS) nixos-vm $(HOME_HOSTS)

.PHONY: help install install-zoltraak install-sasurai install-nixos-vm \
        deploy deploy-sasurai deploy-zoltraak \
        rebuild rebuild-sasurai rebuild-zoltraak \
        push-sasurai push-zoltraak \
        home home-frieren \
        sign-host-certs print-cert-authority \
        sign-user-certs init-identity \
        capture-host-key capture-host-keys seed-host-key \
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
# The per-host SSH host key (config/$(1)/ssh/ssh_host_ed25519_key.age) is
# decrypted ONCE here (passphrase prompt) and seeded into the target's
# /persist/etc/ssh via --extra-files, so agenix has its bootstrapping
# identity on the very first boot. Hosts without a captured key are installed
# without seeding (fresh random host key is generated instead).
define INSTALL_RECIPE
	@hostkey_age="config/$(1)/ssh/ssh_host_ed25519_key.age"; \
	seed=""; \
	fs=$$(mktemp -d); \
	trap 'shred -u "$(LUKS_KEY)" 2>/dev/null || rm -f "$(LUKS_KEY)"; rm -rf "$$fs"' EXIT; \
	if [ -f "$$hostkey_age" ]; then \
	  echo "Host key found for $(1), seeding into persist (passphrase prompt)..."; \
	  install -d -m700 "$$fs/persist/etc/ssh"; \
	  $(AGE) -d -o "$$fs/persist/etc/ssh/ssh_host_ed25519_key" "$$hostkey_age" \
	    || { echo "Host key decrypt failed." >&2; exit 1; }; \
	  chmod 600 "$$fs/persist/etc/ssh/ssh_host_ed25519_key"; \
	  cp "config/$(1)/ssh/ssh_host_ed25519_key.pub" "$$fs/persist/etc/ssh/"; \
	  chmod 644 "$$fs/persist/etc/ssh/ssh_host_ed25519_key.pub"; \
	  seed="$$fs"; \
	else \
	  echo "No captured host key for $(1), installing without seeding."; \
	fi; \
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

install-nixos-vm: ## Full reinstall of the incus VM (no LUKS; prompts for user/host and confirmation)
	$(call INSTALL_RECIPE,nixos-vm,)

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

# Private key of the Host CA (distinct from the user CA). Expand a leading ~
# here because make would otherwise pass it through literally.
HOST_CA_KEY ?= $(HOME)/certs/hosts_certificate_authority
HOST_CA     := $(subst ~,$(HOME),$(HOST_CA_KEY))

# per-host cert principals: the names/IPs clients use to reach each host.
# The wildcards let clients reach either host through any *.home.arpa /
# *.emanon.dev name while still validating against the Host CA.
HOST_PRINCIPALS := zoltraak:zoltraak,zoltraak.home.arpa,192.168.5.113,*.home.arpa,*.emanon.dev \
                   sasurai:sasurai,sasurai.home.arpa,*.home.arpa,*.emanon.dev

sign-host-certs: ## Re-sign all host certificates with the Host CA (HOST_CA_KEY=...)
	@test -f "$(HOST_CA)" || { echo "Host CA key not found: $(HOST_CA)"; exit 1; }
	@for hp in $(HOST_PRINCIPALS); do \
	  h=$${hp%%:*}; p=$${hp#*:}; \
	  ssh-keygen -s "$(HOST_CA)" -I "$$h host cert" -h -n "$$p" \
	    config/$$h/ssh/ssh_host_ed25519_key.pub; \
	done
	@if [ -f "$(HOST_CA).pub" ]; then \
	  read -r t k _ < "$(HOST_CA).pub"; echo "$$t $$k emanon host CA"; \
	else \
	  ssh-keygen -y -f "$(HOST_CA)" | awk '{ print $$1, $$2, "emanon host CA" }'; \
	fi > modules/ssh/host_ca.pub
	@echo "Re-signed host certs for: $(NIXOS_HOSTS)"; \
	echo "Host CA public key written to modules/ssh/host_ca.pub:"; \
	echo "  $$(cut -d' ' -f1,2 modules/ssh/host_ca.pub)"

print-cert-authority: ## Print the @cert-authority line clients need in ~/.ssh/known_hosts
	@echo "@cert-authority \"*.home.arpa,*.emanon.dev\" $$(cut -d' ' -f1,2 modules/ssh/host_ca.pub)"

# ---------------------------------------------------------------------------
# User SSH identity (client certs, signed by the *user* CA)
# ---------------------------------------------------------------------------

# Private key of the User CA. This is the trust root that issues the per-host
# identity certificates; it lives on this machine only and NEVER in the repo.
USER_CA_KEY ?= $(HOME)/certs/users_certificate_authority
USER_CA     := $(subst ~,$(HOME),$(USER_CA_KEY))

# The user identity key for a given host. Defaults to $HOME/.ssh/id_ed25519;
# pass IDENTITY=... to point at a per-host key (e.g. $HOME/.ssh/<host>/id_ed25519).
IDENTITY ?= $(HOME)/.ssh/id_ed25519

# Principals the user identity cert is valid for (usernames on the servers).
USER_PRINCIPALS ?= emanon,root

sign-user-certs: ## Sign one host's user identity cert (HOST=x, USER_CA_KEY=...)
	@test -n "$(HOST)" || { echo "Usage: make sign-user-certs HOST=sasurai"; exit 1; }
	@test -f "$(USER_CA)" || { echo "User CA key not found: $(USER_CA)"; exit 1; }
	@test -f config/$(HOST)/ssh/id_ed25519.pub || { echo "Missing config/$(HOST)/ssh/id_ed25519.pub - run make init-identity HOST=$(HOST) first"; exit 1; }
	@ssh-keygen -s "$(USER_CA)" -I emanon -n $(USER_PRINCIPALS) \
	  -V -52w:+52w config/$(HOST)/ssh/id_ed25519.pub
	@echo "Signed $(HOST)'s user identity cert -> config/$(HOST)/ssh/id_ed25519-cert.pub (principals: $(USER_PRINCIPALS), 1 year validity)"

init-identity: ## Encrypt one host's identity to its own host key + stage pub (HOST=x [IDENTITY=y])
	@test -n "$(HOST)" || { echo "Usage: make init-identity HOST=sasurai"; exit 1; }
	@test -f "$(IDENTITY)" || { echo "Identity key not found: $(IDENTITY)"; exit 1; }
	@mkdir -p config/$(HOST)/ssh
	@hostkey="config/$(HOST)/ssh/ssh_host_ed25519_key.pub"; \
	test -f "$$hostkey" || { echo "Missing $$hostkey - run make capture-host-key HOST=$(HOST) first." >&2; exit 1; }; \
	$(AGE) -e -R "$$hostkey" -o config/$(HOST)/ssh/id_ed25519.age "$(IDENTITY)"
	@cp "$(IDENTITY).pub" config/$(HOST)/ssh/id_ed25519.pub
	@chmod 644 config/$(HOST)/ssh/id_ed25519.pub
	@if [ -f "$(IDENTITY)-cert.pub" ]; then cp "$(IDENTITY)-cert.pub" config/$(HOST)/ssh/id_ed25519-cert.pub; chmod 644 config/$(HOST)/ssh/id_ed25519-cert.pub; \
	else echo "No $(IDENTITY)-cert.pub - run make sign-user-certs HOST=$(HOST) to mint one."; fi
	@echo "Identity for $(HOST) staged. Sealed copy: config/$(HOST)/ssh/id_ed25519.age. Public: config/$(HOST)/ssh/id_ed25519.{pub,-cert.pub}"

# ---------------------------------------------------------------------------
# Per-host SSH host keys (the deterministic agenix bootstrap identity).
# These are the ONE secret NOT managed by agenix: they are passphrase-encrypted
# in config/<host>/ssh/ and decrypted (password prompt) only at first install.
# ---------------------------------------------------------------------------

NIXOS_VM_IP ?= 10.188.165.117

# SSH target per host used by `capture-host-keys` (override as needed).
SSH_HOST_TARGET_sasurai   ?= sasurai.home.arpa
SSH_HOST_TARGET_zoltraak  ?= zoltraak.home.arpa
SSH_HOST_TARGET_frieren   ?= frieren.emanon.dev
SSH_HOST_TARGET_nixos-vm  ?= $(NIXOS_VM_IP)

capture-host-key: ## Capture one host's SSH host key (HOST=x [SSH_TARGET=y] [SSH_USER=z])
	@test -n "$(HOST)" || { echo "Usage: make capture-host-key HOST=sasurai"; exit 1; }
	@target="$(SSH_TARGET)"; [ -n "$$target" ] || target="$(SSH_HOST_TARGET_$(HOST))"; \
	ssh_user="$(SSH_USER)"; [ -n "$$ssh_user" ] || ssh_user="$(USER)"; \
	[ -n "$$target" ] || { echo "No SSH target known for $(HOST) - pass SSH_TARGET=..."; exit 1; }; \
	echo "Capturing /persist/etc/ssh keys of $(HOST) via $${ssh_user}@$$target ..."; \
	mkdir -p "config/$(HOST)/ssh"; \
	ssh "$${ssh_user}@$$target" 'sudo -n cat /persist/etc/ssh/ssh_host_ed25519_key' > "config/$(HOST)/ssh/ssh_host_ed25519_key" || exit 1; \
	ssh "$${ssh_user}@$$target" 'cat /persist/etc/ssh/ssh_host_ed25519_key.pub' > "config/$(HOST)/ssh/ssh_host_ed25519_key.pub" || exit 1; \
	chmod 600 "config/$(HOST)/ssh/ssh_host_ed25519_key"; \
	echo "Encrypting host key (passphrase prompt) - save it in your password manager:"; \
	$(AGE) -p -o "config/$(HOST)/ssh/ssh_host_ed25519_key.age" "config/$(HOST)/ssh/ssh_host_ed25519_key"; \
	shred -u "config/$(HOST)/ssh/ssh_host_ed25519_key"; \
	echo "Stored: config/$(HOST)/ssh/ssh_host_ed25519_key{.age,.pub}"

capture-host-keys: ## Capture host keys for every host (loop over HOST_KEY_HOSTS)
	@for h in $(HOST_KEY_HOSTS); do \
	  echo "=== $$h ==="; \
	  $(MAKE) capture-host-key HOST=$$h || echo "!! failed to capture $$h"; \
	done

seed-host-key: ## Decrypt a host key into a local persist mount (HOST=x [PERSIST_MOUNT=y])
	@test -n "$(HOST)" || { echo "Usage: make seed-host-key HOST=sasurai"; exit 1; }
	@mount="$(PERSIST_MOUNT)"; [ -n "$$mount" ] || mount="/persist"; \
	keyage="config/$(HOST)/ssh/ssh_host_ed25519_key.age"; \
	test -f "$$keyage" || { echo "Missing $$keyage - run capture-host-key first."; exit 1; }; \
	mkdir -p "$$mount/etc/ssh"; \
	echo "Decrypting host key into $$mount/etc/ssh (passphrase prompt):"; \
	$(AGE) -d -o "$$mount/etc/ssh/ssh_host_ed25519_key" "$$keyage" || exit 1; \
	cp "config/$(HOST)/ssh/ssh_host_ed25519_key.pub" "$$mount/etc/ssh/"; \
	chmod 600 "$$mount/etc/ssh/ssh_host_ed25519_key"; \
	chmod 644 "$$mount/etc/ssh/ssh_host_ed25519_key.pub"; \
	echo "Seeded $$mount/etc/ssh/ssh_host_ed25519_key{,.pub}"

# ---------------------------------------------------------------------------
# Flake maintenance
# ---------------------------------------------------------------------------

update: ## Update every flake input
	nix flake update

check: ## Evaluate all configurations
	nix flake check

fmt: ## Format flake with alejandra
	nix run nixpkgs#alejandra -- .
