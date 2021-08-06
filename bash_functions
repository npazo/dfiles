#############
# BASH
############

bump_version(){
	# Set period as delimiter
	IFS='.'
	read -a SPLIT_VERSION <<< "$1"

	MAJOR=${SPLIT_VERSION[0]}
	MINOR=${SPLIT_VERSION[1]}
	PATCH=${SPLIT_VERSION[2]}

	if [ $2 == "major" ]; then
		MAJOR=$((MAJOR+=1))
		MINOR=0
		PATCH=0
	elif [ $2 == "minor" ]; then
		MINOR=$((MINOR+=1))
		PATCH=0
	elif [ $2 == "patch" ]; then
		PATCH=$((PATCH+=1))
	else
		echo "error"
	fi

	echo "$MAJOR.$MINOR.$PATCH"
}

# delete a line number for known hosts, for those pesky times the same DNS is used for a new server
del_known() {
	sed -i.bak "$1d" ~/.ssh/known_hosts
}

# find shorthand. https://github.com/murshidazher/dotfiles/blob/main/bash/.functions
f() {
  find / -name "$1" 2>&1 | grep -v -e 'Permission denied' -e 'Operation not permitted'
}

# Create a new directory and enter it
mkd() {
	mkdir -p "$@"
	cd "$@" || exit
}

tunnel() {
  server_ip=$3
  bastion_ip=$2
  key_name=$1
 	set -x
  ssh -i ~/.ssh/$key_name.pem ec2-user@$server_ip -o ProxyCommand="ssh -i ~/.ssh/$key_name.pem -W %h:%p -q ec2-user@$bastion_ip"
	set +x
}

tunnelscp() {
	server_ip=$3
	bastion_ip=$2
	key_name=$1
	set -x
	scp -i ~/.ssh/$key_name.pem  -o ProxyCommand="ssh -i ~/.ssh/$key_name.pem -W %h:%p -q ec2-user@$bastion_ip" "${@:3}"
	set +x
}

#############
# DOCKER
############

dcleanup(){
	local containers
	containers=( $(docker ps --filter status=exited -q 2>/dev/null) )
	docker rm "${containers[@]}" 2>/dev/null
	local images
	images=( $(docker images --filter dangling=true -q 2>/dev/null) )
	docker rmi "${images[@]}" 2>/dev/null
 	local dangling_volumes
	dangling_volumes=( $(docker volume ls -qf dangling=true) )
  	docker volume rm "${dangling_volumes[@]}" 2>/dev/null
}

ddel_stopped(){
	local name=$1
	local state
	state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm "$name"
	fi
}

ddel_image(){
	docker images -a \
	| grep "$1" \
	| awk '{printf "%s:%s\n",$1,$2}' \
	| xargs docker rmi
}

#############
# GIT
############

git_email() {
	wd=`pwd`
	echo "[includeIf \"gitdir:$wd/\"]" >> ~/.gitconfig.local
	echo -e '\t'"path = .gitconfig.$1" >> ~/.gitconfig.local
}

# Copy just different files between current branch and master to a subfolder
git_save() {
	tmpDir="./git.diff.files"
	gitRoot=`git rev-parse --show-toplevel`
	mkdir $tmpDir
	git diff --name-only --diff-filter=AM master | while read -r line || [[ -n "$line" ]]; do
	    ditto $gitRoot/$line $tmpDir/$line
	done
}

pr() {
  branch=`git rev-parse --abbrev-ref HEAD`
  github_url=`git remote get-url origin | sed 's/....$//'`
  open $github_url/compare/$branch?expand=1
}

#############
# Python
############
check_reqs () {
	regex_home=$(echo "${HOME}" | sed -e 's/\//\\\//g' )
	req_files=`locate requirements.txt | grep 'src/.*requirements.txt'`
	packages=()
	for f in $req_files
	do
 		lines=$(cat $f)
		for line in $lines
		do
			if [[ $line == *"=="* ]]; then
				packages+=(`echo $line | cut -d'=' -f 1`)
				echo "$line ($f)" | sed "s/$regex_home/~/" >> /tmp/check_reqs
			fi
		done
	done
	sort /tmp/check_reqs

	## sort and filter unique packages
	packages=($(printf "%s\n" "${packages[@]}" | sort -u))

	printf "\n\nLatest Versions\n-----------------------\n"

	for p in ${packages[@]}
	do
		version=`get_latest_pypi_version ${p}`
		echo "$p ($version)"
	done

	rm /tmp/check_reqs

}

# helper function for get_latest_pypi_version https://www.linuxjournal.com/content/parsing-rss-news-feed-bash-script
xmlgetnext () {
   local IFS='>'
   read -d '<' TAG VALUE
}

# pass in a URL to a PyPi RSS feed and it splits out the latest version
get_latest_pypi_version () {
	url="https://pypi.org/rss/project/${1}/releases.xml"
	item_flag="false"

	curl -s $url | while xmlgetnext ; do
		if [[ $TAG == "item" && $item_flag == "false" ]]; then
			item_flag="true"
		elif [[ $item_flag == "true" ]]; then
			echo $VALUE
			return
		fi
	done
}