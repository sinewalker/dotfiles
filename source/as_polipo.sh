function polipo() {
	local usage="Usage: $0 [-h|--help] [start|stop|status]"

	(($#)) || {
		echo "$usage" >&2
		return 1
	}

	case "$1" in
		start) sudo launchctl load -F /Library/LaunchDaemons/homebrew.mxcl.polipo.plist;;
		stop) sudo launchctl unload -F /Library/LaunchDaemons/homebrew.mxcl.polipo.plist;;
		status) sudo launchctl list | grep polipo;;
		-h|--help) echo "$usage";;
		*) echo "Unknown command: $1"; echo "$usage" >&2; return 1;;
	esac
}
export -f polipo

