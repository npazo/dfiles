#  Customize BASH PS1 prompt to show current GIT repository and branch.
#  by Mike Stewart - http://MediaDoneRight.com

#  SETUP CONSTANTS
#  Bunch-o-predefined colors.  Makes reading code easier than escape sequences.
#  I don't remember where I found this.  o_O

GIT_PS1_SHOWUNTRACKEDFILES=true

export EDITOR=vim
export HISTCONTROL="erasedups:ignoreboth"       # no duplicate entries
export HISTSIZE=50000000                          # big big history (default is 500)
export HISTFILESIZE=$HISTSIZE                   # big big history
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
type shopt &> /dev/null && shopt -s histappend  # append to history, don't overwrite it

# apt install source-highlight
if [ -f /usr/bin/src-hilite-lesspipe.sh ]; then	
	export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
	export LESS=' -R '
fi

if [ -x /usr/bin/dircolors ]; then
	# shellcheck disable=SC2015
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# Various variables you might want for your PS1 prompt instead
Time12h="\T"
Time12a="\@"
PathShort="\w"
PathFull="\W"
NewLine="\n"
Jobs="\j"
Apple=""

if tput setaf 1 &> /dev/null; then
	tput sgr0; # reset colors
	bold=$(tput bold);
	reset=$(tput sgr0);
	# Solarized colors, taken from http://git.io/solarized-colors.
	black=$(tput setaf 0);
	blue=$(tput setaf 33);
	cyan=$(tput setaf 37);
	green=$(tput setaf 64);
	orange=$(tput setaf 166);
	purple=$(tput setaf 125);
	red=$(tput setaf 124);
	violet=$(tput setaf 61);
	white=$(tput setaf 15);
	yellow=$(tput setaf 136);
else
	bold='';
	reset="\\e[0m";
	# shellcheck disable=SC2034
	black="\\e[1;30m";
	blue="\\e[1;34m";
	cyan="\\e[1;36m";
	green="\\e[1;32m";
	# shellcheck disable=SC2034
	orange="\\e[1;33m";
	# shellcheck disable=SC2034
	purple="\\e[1;35m";
	red="\\e[1;31m";
	violet="\\e[1;35m";
	white="\\e[1;37m";
	yellow="\\e[1;33m";
fi;

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
	userStyle="${red}";
else
	userStyle="${blue}";
fi;


hostnameStyle="h"
# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
	hostStyle="${yellow}";
	hostnameStyle="H"
else
	hostStyle="${cyan}";
fi;

cloud=""
if [[ -e /var/lib/cloud/instance ]]; then
        cloud="☁️  "
fi

prompt_git() {
	local s='';
	local branchName='';

	# Check if the current directory is in a Git repository.
	if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}")" == '0' ]; then

		# check if the current directory is in .git before running git checks
		if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

			if [[ -O "$(git rev-parse --show-toplevel)/.git/index" ]]; then
				git update-index --really-refresh -q &> /dev/null;
			fi;

			# Check for uncommitted changes in the index.
			if ! git diff --quiet --ignore-submodules --cached; then
				s+='+';
			fi;

			# Check for unstaged changes.
			if ! git diff-files --quiet --ignore-submodules --; then
				s+='!';
			fi;

			# Check for untracked files.
			if [ -n "$(git ls-files --others --exclude-standard)" ]; then
				s+='?';
			fi;

			# Check for stashed files.
			if git rev-parse --verify refs/stash &>/dev/null; then
				s+='$';
			fi;

		fi;

		# Get the short symbolic ref.
		# If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
		# Otherwise, just give up.
		branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
			git rev-parse --short HEAD 2> /dev/null || \
			echo '(unknown)')";

		[ -n "${s}" ] && s=" [${s}]";

		echo -e "${1}${branchName}${yellow}${s}";
		
	else
		return;
	fi;
}

#PS1="\[$(tput setaf 6)\]\W\[$(tput sgr0)\]\[$(tput sgr0)\] "
PS1="";
# Set the terminal title to the current working directory.
PS1="\\[\\033]0;\\w\\007\\]";
# PS1+="\\[${bold}\\]\\n"; # newline
PS1+="↪ \\[${userStyle}\\]\\u"; # username
PS1+="\\[${white}\\] at ";
PS1+="\\[${hostStyle}\\]${cloud}\\${hostnameStyle}"; # host
PS1+="\\[${white}\\] in ";
PS1+="\\[${green}\\]\\w "; # working directory
PS1+="\$(prompt_git \"${violet}\")"; # Git repository details
PS1+="\\n";
PS1+="\\[${bold}\\]\\[${orange}\\]\$ \\[${reset}\\]"; # `$` (and reset color)
export PS1;

PS2="\\[${yellow}\\]→ \\[${reset}\\]";
export PS2;