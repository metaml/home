.DEFAULT_GOAL = help

MAKESHELL = /bin/bash
OS = $(shell uname -s)
export PATH := ${HOME}/.nix-profile/bin:/usr/bin:/usr/sbin:/bin

update: ## update nix packages--and then make clean
	nix-channel --update
	nix-env --upgrade --always

clean: ## collect garbage
	rm -f /nix/var/nix/gcroots/auto/*
	nix-collect-garbage --delete-old

channel: ## add nix channels
	nix-channel --add https://nixos.org/channels/nixpkgs-unstable
	if [ "Darwin" = "$(OS)" ]; \
	  then nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin; \
	fi
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

init: ## install nix
	curl --location https://nixos.org/nix/install --output /tmp/nix-install
	chmod +x /tmp/nix-install
	if [ "Darwin" = "$(OS)" ]; \
	  then /tmp/nix-install --darwin-use-unencrypted-nix-store-volume; \
	  else /tmp/nix-install; \
	fi
	nix-env --install --attr nixpkgs.nixUnstable
	@echo "NB: \"experimental-features = nix-command flakes\" to ~/.config/nix/nix.conf"

help: ## help
	-@grep --extended-regexp '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sed 's/^Makefile://1' \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'
	-@echo PATH=${PATH}
