#!/usr/bin/env bash
# install nix befor running this script!!!
# you can install Nix with:
# sh <(curl -L https://nixos.org/nix/install) --daemon

# install Home Manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# enable flakes
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf

pushd ~/nix-config/ || exit 1

# build flake and switch to it
home-manager build --flake .#andrew
rm ~/.ssh/config ~/.bashrc ~/.profile
./result/activate

popd || exit 1
