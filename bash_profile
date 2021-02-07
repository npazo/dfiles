for file in ~/.{aliases,bashrc,bash_functions,dockerfunc,git_prompt,git-completion.bash}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
done