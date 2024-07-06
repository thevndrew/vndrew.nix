#!/usr/bin/env bash
HOST=polar-tang

# setup SSH key
mkdir ~/.ssh
cp /mnt/c/Users/AJ-XPS/.ssh/$HOST* ~/.ssh
chmod 600 ~/.ssh/$HOST*
chmod 700 ~/.ssh
cat >~/.ssh/config <<EOL
Host github.com
  User git
  IdentityFile ~/.ssh/$HOST
EOL

# pull config flake
git clone git@github.com:thevndrew/nix-config.git ~/nix-config

if ! grep -q systemd /etc/wsl.conf; then
	# enable systemd
	cat <<EOL | tee -a /etc/wsl.conf
[boot]
systemd=true
EOL
fi
