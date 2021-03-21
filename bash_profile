for file in ~/.{aliases,bashrc,bash_functions,dockerfunc,git-completion.bash,localdfiles/**}; do		
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null		
		source "$file"
	fi
done

export PATH="$HOME/.bin:$PATH"