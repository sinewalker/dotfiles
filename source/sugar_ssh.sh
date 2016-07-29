export squiz_user=mlockhart@  #dirty hack

function ssh_host() {
	if ! (($#))
	then
		echo "Syntax: ssh_host <vz_guest>"
		return 0
	fi

	local vz_guest=$1
  ssh -t ${squiz_user}$(host -t txt $vz_guest.syd.ipowered.com.au | awk -F\" 'END { print $(NF - 1)}')
}
export -f ssh_host

function ssh_guest() {
	if ! (($#))
	then
		echo "Syntax: ssh_guest <vz_guest> [site_name]"
		return 0
	fi

	local vz_guest="$1"
	local site="$2"

  ssh -t ${squiz_user}$(host -t txt $vz_guest.syd.ipowered.com.au | awk -F\" 'END { print $(NF - 1)}') "/bin/bash --login -c 'enter_host $vz_guest $site'"
}
export -f ssh_guest

function ssh_site() {
	local vz_guest site=$1

	if [ $# -lt 1 ]; then
		echo "Syntax: ssh_site <site_name>"
		return 0
	fi

	# if we get a full name, we'll follow it to the last alias
	local fqdn_regex="^[^.]+\..+"
	if [[ $site =~ $fqdn_regex ]]
	then
		if ! vz_guest=$(host "$site" | awk -F. '/has address/ {print $1}')
		then
			echo "Error getting guest VM name from FQDN ($site)" >&2
			return 1
		fi

		site=${site%%.*}
	else
		vz_guest=$(host -t a $site.insightfulcrm.com | awk -F. 'END {print $1}')
	fi


	if [[ "$vz_guest" != "$site" ]]; then
    ssh -t ${squiz_user}$(host -t txt $vz_guest.syd.ipowered.com.au | awk -F\" 'END { print $(NF - 1)}') "/bin/bash --login -c 'enter_host $vz_guest $site'"
	else
		echo "Site $site does not exist!"
		return 1
	fi
}

# take fqdn, if it's .mq.edu.au, trace down to the last name
