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

if ! which starship; then
	log "Installing starship."
	sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes
else
	log "Starship is installed. Skipping."
fi

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

if ! which ocaml; then
	log "Installing OCaml and OPAM."
	sudo pacman -S --noconfirm opam
	opam init --shell-setup --disable-shell-hook
	eval $(opam env)
	opam switch create 4.12.0
	eval $(opam env)
else
	log "OCaml is already installed. Skipping."
fi

if ! which coqc; then
	log "Installing Coq."
	opam install opam-depext
	eval $(opam env)
	opam-depext coq --yes
	opam pin add coq 8.13.1 --yes
else
	log "Coq is already installed. Skipping."
fi

if ! which javac; then
	log "Installing Java (OpenJDK 16)."
	sudo pacman -S --noconfirm openjdk-16-jdk-headless
else
	log "Java is already installed. Skipping."
fi

log "Installing some other packages."
sudo pacman -S --noconfirm xauth emacs neovim

log "Sanity check:"
log "  yadm:  $(which yadm)"
log "  rustc: $(which rustc)"
log "  node:  $(which node)"
log "  ocaml: $(which ocaml)"
log "  opam:  $(which opam)"
log "  coqc:  $(which coqc)"
log "  javac: $(which javac)"
