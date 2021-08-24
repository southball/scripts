#!/bin/bash

# Stop the script on fail.
set -e

RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'
function log() {
	printf "$YELLOW$*$NC\n"
}

if ssh -T git@github.com 2>&1 | grep -q "successfully"; then
	log "SSH key is already configured."
else
	log "Please make sure your SSH key is already configured so required projects can be cloned."
	exit 1
fi

cd $HOME

if [ ! -f "/usr/local/bin/pacapt" ]; then
	log "Installing pacapt."
	sudo wget -O /usr/local/bin/pacapt https://github.com/icy/pacapt/raw/ng/pacapt
	sudo chmod 755 /usr/local/bin/pacapt
	sudo ln -sv /usr/local/bin/pacapt /usr/local/bin/pacman || true
else
	log "pacapt is already installed. Skipping installation."
fi

log "Updating system packages."
sudo pacman -Syu --noconfirm

log "Installing required packages."
sudo pacman -S --noconfirm build-essential yadm 

log "Configuring Git."
git config --global user.email "jamie.choi.mail.2002@gmail.com"
git config --global user.name "Southball"

if [ ! -d "$HOME/.config/yadm" ]; then
	log "Copying dotfiles using yadm."
	pushd $HOME
	yadm clone -f git@github.com:southball/dotfiles.git
	popd
else
	log "Yadm is already initialized. Skipping."
fi

if [ ! -f "$HOME/.cargo/bin/rustup" ]; then
	log "Installing required packages."
        sudo pacman -S --noconfirm pkg-config libssl-dev
	log "Installing Rust toolchain."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --quiet -y
	source $HOME/.cargo/env
	cargo install cargo-edit
else
	log "Rust toolchain is already installed. Skipping."
fi

if ! which node; then
	log "Installing NodeJS."
	curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
	sudo pacman -S --noconfirm nodejs
else
	log "NodeJS is already installed. Skipping."
fi

#log "Installing OCaml and OPAM."
#sudo pacman -S --noconfirm opam

#if ! which ; then
#	log "Installing Coq."
#	opam init --disable-sandboxing --disable-shell-hook
#else
#	log "Coq is already installed. Skipping."
#fi

log "Installing some other packages."
sudo pacman -S --noconfirm xauth

log "Sanity check:"
log "  yadm:  $(which yadm)"
log "  rustc: $(which rustc)"
log "  node:  $(which node)"
log "  ocaml: $(which ocaml)"
log "  opam:  $(which opam)"
