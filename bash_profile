# [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

base_files=("aliases" "bash_functions" "dockerfunc" "localdfiles/**")

if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
   base_files+=("")
elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
	test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
   base_files=("git-completion.bash" "bashrc" "${base_files[@]}")
#else
   # assume something else
fi

# for file in $HOME/.{git-completion.bash,aliases,bashrc,bash_functions,dockerfunc,localdfiles/**}; do
for file in "${base_files[@]}"; do
	if [[ -r "$HOME/.$file" ]] && [[ -f "$HOME/.$file" ]]; then
		# shellcheck source=/dev/null\
		# echo "$HOME/.$file"
		source "$HOME/.$file"
	fi
done


# export PATH="$HOME/.bin:$PATH"

