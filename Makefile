# NixOS / home-manager maintenance targets.
#
#   make help                 list all targets
#   make deploy-zoltraak      build locally + copy closure + switch zoltraak (no OOM)
#   make deploy               build locally + switch every NixOS host
#   make rebuild-zoltraak     sync flake + rebuild + switch zoltraak (on the machine)
#   make install-zoltraak     full reinstall of zoltraak via nixos-anywhere (destructive!)
#   make update               update flake lockfile
#
# Override at the command line, e.g.:
#   make rebuild-sasurai SASURAI_IP=192.168.5.99

SHELL := bash
MAKEFLAGS += --no-print-directory

USER        ?= emanon
FLAKE       := .

# Hosts with full NixOS deployments.
NIXOS_HOSTS := sasurai zoltraak

ZOLTRAAK_IP ?= 192.168.5.113
SASURAI_IP  ?= sasurai

FLAMME_IP ?= $(shell incus list flamme --format csv -c 4 2>/dev/null | head -n1 | sed -E 's/^"?([0-9.]+).*/\1/')

# Tools are run via `nix run` since they aren't installed on this machine.
ANYWHERE       := nix run github:nix-community/nixos-anywhere --
NIXOS_REBUILD  := nix run nixpkgs\#nixos-rebuild --
AGE            := nix run nixpkgs\#age --

ZOLTRAAK := $(USER)@$(ZOLTRAAK_IP)
SASURAI  := $(USER)@$(SASURAI_IP)
FLAMME := $(USER)@$(FLAMME_IP)

# Temporary file the LUKS passphrase is written to during installs and
# deleted afterwards.
LUKS_KEY ?= /tmp/disk-encryption.key

HOST_CA_KEY ?= $(HOME)/certs/hosts_certificate_authority
HOST_CA := $(subst ~,$(HOME),$(HOST_CA_KEY))

.PHONY: help install install-zoltraak install-sasurai install-fern install-flamme \
        deploy deploy-sasurai deploy-zoltraak deploy-flamme \
        rebuild rebuild-sasurai rebuild-zoltraak rebuild-flamme \
        push-sasurai push-zoltraak push-flamme \
        print-cert-authority sign-fern-host-cert \
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
# $(3) is the identity host whose host key is seeded; it defaults to $(1).
#
# nixos-anywhere is also passed -i so it logs in with the host's own identity
# instead of generating a throwaway key and then demanding a password, which
# these hosts do not have.
#
# There is no separate key to unlock: configs/<key_host>/ssh/id_ed25519.age is
# sealed to that same host key (agenix.nix makes it the only age.identityPath),
# so the passphrase above that opens the host key also opens the identity. It
# goes to its own mktemp file, NOT into $$fs, because --extra-files copies all
# of $$fs onto the target's / - and the trap shreds it, so nothing plaintext is
# left on disk. IDENTITY= overrides this with an already-decrypted key.
#
# The static host key (configs/<identity>/ssh/ssh_host_ed25519_key.age) is
# decrypted ONCE here (passphrase prompt) and seeded into the target's
# /persist/etc/ssh via --extra-files, so agenix has its deterministic bootstrap
# identity on the very first boot.
define INSTALL_RECIPE
	@key_host="$(if $(3),$(3),$(1))"; \
	hostkey_age="configs/$${key_host}/ssh/ssh_host_ed25519_key.age"; \
	test -f "$$hostkey_age" || { echo "Missing $$hostkey_age - commit a host key for $${key_host} first." >&2; exit 1; }; \
	identity="$${IDENTITY:-}"; \
	idpath="$$(mktemp)"; \
	idflag=""; \
	fs=$$(mktemp -d); \
	trap 'shred -u "$$idpath" 2>/dev/null || rm -f "$$idpath"; shred -u "$(LUKS_KEY)" 2>/dev/null || rm -f "$(LUKS_KEY)"; rm -rf "$$fs"' EXIT; \
	echo "Seeding $${key_host} host key into persist for agenix bootstrap (passphrase prompt)..."; \
	install -d -m700 "$$fs/persist/etc/ssh"; \
	$(AGE) -d -o "$$fs/persist/etc/ssh/ssh_host_ed25519_key" "$$hostkey_age" \
	  || { echo "Host key decrypt failed." >&2; exit 1; }; \
	chmod 600 "$$fs/persist/etc/ssh/ssh_host_ed25519_key"; \
	cp "configs/$${key_host}/ssh/ssh_host_ed25519_key.pub" "$$fs/persist/etc/ssh/"; \
	chmod 644 "$$fs/persist/etc/ssh/ssh_host_ed25519_key.pub"; \
	if [ -f "configs/$${key_host}/ssh/ssh_host_ed25519_key-cert.pub" ]; then \
	  cp "configs/$${key_host}/ssh/ssh_host_ed25519_key-cert.pub" "$$fs/persist/etc/ssh/"; \
	  chmod 644 "$$fs/persist/etc/ssh/ssh_host_ed25519_key-cert.pub"; \
	fi; \
	if [ -n "$$identity" ]; then \
	  test -f "$$identity" || { echo "IDENTITY=$$identity does not exist." >&2; exit 1; }; \
	  idflag="-i $$identity"; \
	elif [ -f "configs/$${key_host}/ssh/id_ed25519.age" ]; then \
	  $(AGE) -d -i "$$fs/persist/etc/ssh/ssh_host_ed25519_key" -o "$$idpath" \
	    "configs/$${key_host}/ssh/id_ed25519.age" \
	    || { echo "Could not open the $${key_host} identity with its host key." >&2; exit 1; }; \
	  chmod 600 "$$idpath"; \
	  idflag="-i $$idpath"; \
	else \
	  echo "WARNING: missing configs/$${key_host}/ssh/id_ed25519.age - nixos-anywhere" >&2; \
	  echo "  will generate a throwaway key and ask for a password these hosts do" >&2; \
	  echo "  not have. Only pass IDENTITY= if you have decrypted one by hand." >&2; \
	fi; \
	seed="$$fs"; \
	read -r -p "SSH username: " ssh_user; \
	read -r -p "Target host or IP: " target_host; \
	if [ -z "$$ssh_user" ] || [ -z "$$target_host" ]; then echo "Aborted."; exit 1; fi; \
	echo; \
	echo "WARNING: you are about to DESTRUCTIVELY reinstall $(1) on $${ssh_user}@$${target_host}."; \
	echo "The target disk will be re-partitioned and ALL its data will be lost."; \
	read -r -p "Type YES to confirm, anything else to abort: " confirm; \
	if [ "$$confirm" != "YES" ]; then echo "Aborted."; exit 1; fi; \
	if [ -n "$$idflag" ] && [ -f "configs/$${key_host}/ssh/id_ed25519.pub" ]; then \
	  echo "Seeding root authorized_keys on the target..."; \
	  certflag=""; \
	  [ -f "configs/$${key_host}/ssh/id_ed25519-cert.pub" ] && certflag="-o CertificateFile=configs/$${key_host}/ssh/id_ed25519-cert.pub"; \
	  ssh_opts="-o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10"; \
	  if [ "$$ssh_user" = "root" ]; then \
	    ssh $$ssh_opts $${idflag} $$certflag "root@$${target_host}" 'mkdir -p /root/.ssh && chmod 700 /root/.ssh && cat >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys' < "configs/$${key_host}/ssh/id_ed25519.pub" \
	      || { echo "Failed to seed /root/.ssh/authorized_keys on $${target_host}." >&2; exit 1; }; \
	  else \
	    ssh $$ssh_opts $${idflag} $$certflag "$${ssh_user}@$${target_host}" 'sudo -n sh -c "mkdir -p /root/.ssh && chmod 700 /root/.ssh && cat >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys"' < "configs/$${key_host}/ssh/id_ed25519.pub" \
	      || { echo "Failed to seed /root/.ssh/authorized_keys on $${target_host}." >&2; exit 1; }; \
	  fi; \
	fi; \
	if [ "$(2)" = "luks" ]; then \
	  read -s -p "LUKS passphrase: " key1; echo; \
	  read -s -p "Confirm LUKS passphrase: " key2; echo; \
	  if [ "$$key1" != "$$key2" ]; then echo "LUKS passphrases do not match." >&2; exit 1; fi; \
	  umask 077; printf '%s\n' "$$key1" > "$(LUKS_KEY)"; \
	fi; \
	$(ANYWHERE) --flake $(FLAKE)#$(1) \
	  $${idflag:+$$idflag} \
	  $(if $(filter luks,$(2)),--disk-encryption-keys /tmp/disk-encryption.key "$(LUKS_KEY)" ,) \
	  $${seed:+--extra-files $$seed} \
	  "$$ssh_user@$$target_host"
endef

install: install-zoltraak install-sasurai ## Full reinstall of every NixOS host (danger!)

install-zoltraak: ## Full reinstall of zoltraak (prompts for user/host, confirmation and LUKS passphrase)
	$(call INSTALL_RECIPE,zoltraak,luks)

install-sasurai: ## Full reinstall of sasurai (prompts for user/host, confirmation and LUKS passphrase)
	$(call INSTALL_RECIPE,sasurai,luks)

install-fern: ## Full reinstall of fern (unencrypted; prompts for user/host and confirmation)
	$(call INSTALL_RECIPE,fern,,fern)

install-flamme: ## Full reinstall of the flamme dev VM (unencrypted; prompts for user/host, host-key passphrase and confirmation)
	$(call INSTALL_RECIPE,flamme,)

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

deploy-flamme: ## Build locally, copy to the flamme dev VM and switch
	$(NIXOS_REBUILD) switch --flake $(FLAKE)#flamme --target-host $(FLAMME) --use-remote-sudo

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

push-flamme: ## Sync the committed flake to the flamme dev VM (~/nix)
	@git archive --format=tar.gz HEAD | ssh $(FLAMME) 'rm -rf ~/nix && mkdir -p ~/nix && tar -xzf - -C ~/nix'

rebuild-flamme: push-flamme ## Rebuild + switch the flamme dev VM on the machine itself
	@ssh $(FLAMME) 'sudo -n nixos-rebuild switch --flake ~/nix#flamme'

# ---------------------------------------------------------------------------
# Host CA (client-side known_hosts entry)
# ---------------------------------------------------------------------------

print-cert-authority: ## Print the @cert-authority line clients need in ~/.ssh/known_hosts
	@echo "@cert-authority \"*.home.arpa,*.emanon.dev\" $$(cut -d' ' -f1,2 modules/ssh/host_ca.pub)"

sign-fern-host-cert: ## Sign fern's repo host key with the Host CA (prompts for the CA passphrase)
	@test -f "$(HOST_CA)" || { echo "Host CA key not found: $(HOST_CA)"; exit 1; }
	ssh-keygen -s "$(HOST_CA)" -I "fern host cert" -h \
	  -n "fern,fern.home.arpa,fern.emanon.dev,fern.home.emanon.dev,192.168.5.30" \
	  -V always:forever configs/fern/ssh/ssh_host_ed25519_key.pub
	@echo "Wrote configs/fern/ssh/ssh_host_ed25519_key-cert.pub"

# ---------------------------------------------------------------------------
# Flake maintenance
# ---------------------------------------------------------------------------

update: ## Update every flake input
	nix flake update

check: ## Evaluate all configurations
	nix flake check

fmt: ## Format flake with alejandra
	nix run nixpkgs#alejandra -- .