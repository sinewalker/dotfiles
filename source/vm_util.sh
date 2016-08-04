function vm_netinfo() {
	[ -z "$1" ] && { echo "Need VM name to inspect"; return 1; }

	VBoxManage showvminfo "$1" --machinereadable | grep macaddress | sed -Ee 's/.*="([^"]+)"/\1/' -e "s/(..)/\1-/g" -e "s/-$//" | tr A-Z a-z
}

function vm_install() {
	[ -z "$1" ] && { echo "Need VM name to install"; return 1; }

	set +e

	sudo /srv/bin/install "$1"
	VBoxManage controlvm "$1" poweroff 2>/dev/null

	ATTEMPTS=10
	while [ $ATTEMPTS -gt 0 ] && ! VBoxManage startvm "$1" 2>/dev/null
	do
		sleep 1
		let "ATTEMPTS = ATTEMPTS - 1"
	done
}

function vm_start() {
	VBoxManage startvm "$1"
}


export -f vm_install vm_start

