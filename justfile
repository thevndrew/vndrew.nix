bash_dir := "config/bash"
zsh_dir := "config/zsh"

wsl-tar hostname="polar-tang":
	nix build ".#nixosConfigurations.{{hostname}}.config.system.build.tarballBuilder"
	sudo ./result/bin/nixos-wsl-tarball-builder
	rm ./result

info:
	nix flake metadata

test flag="":
	nh os test {{flag}}

switch flag="":
	nh os switch {{flag}}

update:
	nix flake update

gc-roots:
	sudo find_gc_roots /nix/store

generations:
	nix profile history --profile /nix/var/nix/profiles/system

optimise:
	nix-store --optimise

update-cmp program:
	{{program}} completion bash > {{bash_dir}}/{{program}}.bash
	{{program}} completion zsh > {{zsh_dir}}/{{program}}.zsh

update-completions:
	@just update-cmp bootdev
	@just update-cmp gitleaks
