#
# this change is mostly because when running a nagios server (which is also a client)
# it attempts to resolve it's hostname which returns 127.0.0.1, however the connection
# is made on the primary interface - this could be fixed by using hostnames everywhere
# in the nagios config...
#

# may need to load the original first..
if not defined? VagrantPlugins::GuestRedHat::Cap::ChangeHostName
	require "vagrant"
#	puts "loading origin plugin from #{Vagrant.source_root}/plugins/guests/redhat/cap/change_host_name"
	require "#{Vagrant.source_root}/plugins/guests/redhat/cap/change_host_name"
end
# now we can override the /etc/hosts updating...
module VagrantPlugins
	module GuestRedHat
		module Cap
			class ChangeHostName
				def update_etc_hosts
					# restart avahi to pick up the new hostname
					# the hostname has already been set at this point so we're OK...
					# This command can/should not fail
					sudo "[[ -f /etc/init.d/avahi-daemon ]] && /etc/init.d/avahi-daemon restart || true"
				end
			end
		end
	end
end

