SHELL := bash

all: clean sync check

sync:
	[ -f ~/.aliases ] || ln -s $(PWD)/aliases ~/.aliases
	[ -f ~/.bash_profile ] || ln -s $(PWD)/bash_profile ~/.bash_profile
	[ -f ~/.bash_functions ] || ln -s $(PWD)/bash_functions ~/.bash_functions
	[ -f ~/.bashrc ] || ln -s $(PWD)/bashrc ~/.bashrc
	[ -f ~/.bin/ ] || ln -s $(PWD)/bin ~/.bin
	[ -f ~/.dockerfunc ] || ln -s $(PWD)/dockerfunc ~/.dockerfunc
	[ -f ~/.git-prompt.sh ] || ln -s $(PWD)/git-prompt.sh ~/.git-prompt.sh
	[ -f ~/.gitconfig ] || ln -s $(PWD)/gitconfig ~/.gitconfig
	[ -f ~/.gitignore_global ] || ln -s $(PWD)/gitignore_global ~/.gitignore_global
	[ -f ~/.ssh/config ] || ln -s $(PWD)/ssh_config ~/.ssh/config
	[ -f ~/.tmux.conf ] || ln -s $(PWD)/tmux.conf ~/.tmux.conf
	[ -f ~/.vimrc ] || ln -s $(PWD)/vimrc ~/.vimrc

	if ! [ -x "$(shell command -v curl)" ]; then \
  		echo 'Error: curl is not installed.'; \
	else \
		curl -s https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o git-completion.bash; \
		[ -f ~/.git-completion.bash ] || ln -s $(PWD)/git-completion.bash ~/.git-completion.bash; \
	fi;

	chmod 600 ~/.ssh/config
	source ~/.bashrc
	
clean:
	rm -f ~/.aliases
	rm -f ~/.bash_functions
	rm -f ~/.bash_profile
	rm -f ~/.bashrc
	rm -f ~/.bin
	rm -f ~/.dockerfunc
	rm -f ~/.git-completion.bash
	rm -f ~/.gitignore_global
	rm -f ~/.git-prompt.sh
	rm -f ~/.gitconfig
	rm -f ~/.ssh/config
	rm -f ~/.tmux.conf
	rm -f ~/.vimrc 

check:
	[ -f ~/.ssh/sshconfig.local ] || echo "WARNING: Local SSH config doesn not exist"
	[ -f ~/.gitconfig.local ] || echo "WARNING: Local Git config doesn not exist"
	[ -f ~/.ansible.cfg ] || echo "WARNING: Local Ansible config doesn not exist"
