bash_dir := "config/bash"
zsh_dir := "config/zsh"

info:
	nix flake metadata

test flag="":
	nh os test {{flag}}

switch flag="":
	nh os switch {{flag}}

update:
	nix flake update

update-cmp program:
	{{program}} completion bash > {{bash_dir}}/{{program}}.bash
	{{program}} completion zsh > {{zsh_dir}}/{{program}}.zsh

update-completions:
	@just update-cmp bootdev
	@just update-cmp gitleaks
