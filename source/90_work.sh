#TODO: review this file -- it is specific for Squiz, and these ipowered hosts
#      are all due to be decommissioned One Day, making this obsolete.

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

################

# to make SQ_CONF_ROOT_URLS into wiki urls
# just enter the URLS followed by EOF
alias wiki_urls='cat <<EOF | sed -re "s^(.*)^|| http://\1 ||^"'

# according to https://opswiki.squiz.net/Policies/Password_Guidelines#GeneralPasswordGuidelines
alias pwgen='pwgen -1 -c -n -y 12'

# we want colour and paging in svn diff commands
svn () {
	# bail if the user didnt specify which subversion command to invoke
	if (( $# < 1 )) || ! [[ -t 1 ]]
	then
		command svn "$@"
		return
	fi

	local sub_cmd=$1
	local pager=cat
	shift

	# abbreviations stolen from 'svn help'
	case $sub_cmd in
		st*|di*|log|blame|praise|ann*|h*|?) pager='less -Rf'
	esac

	#intercept svn diff commands
	if [[ $sub_cmd == diff ]]
	then

		# colorize the diff
		# remove stupid ^M dos line endings
		# page it if there's more one screen
		command svn diff "$@" | colordiff | sed -e "s/\\\r//g"

	# add some color to svn status output and page if needed:
	# M = blue
	# A = green
	# D/!/~ = red
	# C = magenta
	#
	#note that C and M can be preceded by whitespace - see $svn help status
	elif [[ $sub_cmd =~ ^(status|st)$ ]]
	then
		command svn status "$@" | sed -e 's/^\(\([A-Z]\s\+\(+\s\+\)\?\)\?C .*\)$/\[1;35m\1[0m/' \
				-e 's/^\(\s*M.*\)$/\[1;34m\1[0m/' \
				-e 's/^\(A.*\)$/\[1;32m\1[0m/' \
				-e 's/^\(\(D\|!\|~\).*\)$/\[1;31m\1[0m/'

	# page some stuff I often end up paging manually
#	elif [[ $sub_cmd =~ ^(blame|help|h|cat)$ ]]
#	then
#		command svn $sub_cmd "$@"

	# colorize and page svn log
	# rearrange the date field from:
	#	 2010-10-08 21:19:24 +1300 (Fri, 08 Oct 2010)
	# to:
	#	 2010-10-08 21:19 (Fri, +1300)
	elif [[ $sub_cmd == log ]]
	then
		command svn log "$@" | sed -e 's/^\(.*\)|\(.*\)| \(.*\) \(.*\):[0-9]\{2\} \(.*\) (\(...\).*) |\(.*\)$/\[1;32m\1[0m|\[1;34m\2[0m| \[1;35m\3 \4 (\6, \5)[0m |\7/'

	#let svn handle it as normal
	else
		command svn "$sub_cmd" "$@"

	# TODO we don't want to page the update command
	fi | $pager
}


function wiid() {
	  ssh squiz-cru01.hba.squiz.net.au "su - wiid -c '~/whyisitdown/whyisitdown $1 "$2"'"
}
export -f wiid
