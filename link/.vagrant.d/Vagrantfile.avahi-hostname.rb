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


Vagrant.configure("2") do |config|
	# I like using mdns for my VMs...
	config.vm.provision :shell, :inline => <<-EOSH
		flavour=$(lsb_release -si)

		case $flavour in
			Scientific|Red[Hh]at) ;;
			*) echo "Not installing mDNS for $flavour"; exit;;
		esac

		echo "Allowing mDNS traffic"
		cat <<-EOF > /etc/sysconfig/iptables
			*filter
			:INPUT ACCEPT [0:0]
			:FORWARD ACCEPT [0:0]
			:OUTPUT ACCEPT [0:0]
			-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
			-A INPUT -p icmp -j ACCEPT
			-A INPUT -i lo -j ACCEPT
			-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
			-A INPUT -p udp -m udp --dport 5353 --destination 224.0.0.251 -j ACCEPT
			-A INPUT -j REJECT --reject-with icmp-host-prohibited
			-A FORWARD -j REJECT --reject-with icmp-host-prohibited
			COMMIT
		EOF
		/etc/init.d/iptables restart

		[[ -f /etc/yum.repos.d/epel.repo ]] && skip=1 || skip=0

		release_ver=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release) | cut -d. -f1)

		#type yum >&/dev/null && yum -y install http://mirror.aarnet.edu.au/pub/epel/6/i386/epel-release-6-8.noarch.rpm
		#type yum >&/dev/null && yum -y install http://mirror.aarnet.edu.au/pub/epel/epel-release-latest-6.noarch.rpm
		#type yum >&/dev/null && yum -y install https://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
		type yum >&/dev/null && yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${release_ver}.noarch.rpm

		((skip)) || {
			# TODO this is fragile
			# can't do this because we need it for puppet :-/
			#sed -i -re "s%enabled(\\s*)=(\\s*)1%enabled\\1=\\20%g" /etc/yum.repos.d/epel.repo
			:
		}

		echo "Enabling multicast DNS for the .local domain"
		# this is the "default", with minor mods for this environment
		cat <<-EOF > /tmp/avahi-daemon.conf
			[server]
			browse-domains=0pointer.de, zeroconf.org
			use-ipv4=yes
			use-ipv6=no
			# see http://archlinuxarm.org/forum/viewtopic.php?f=31&t=6408#p35911
			disallow-other-stacks=yes

			[wide-area]
			enable-wide-area=yes

			[publish]

			[reflector]

			[rlimits]
			rlimit-core=0
			rlimit-data=4194304
			rlimit-fsize=0
			rlimit-nofile=300
			rlimit-stack=4194304
			rlimit-nproc=3
		EOF
		type yum >&/dev/null && yum -y --enablerepo=epel install nss-mdns && {
			cp /etc/avahi/avahi-daemon.conf /etc/avahi/avahi-daemon.conf.orig
			mv -f /tmp/avahi-daemon.conf /etc/avahi/avahi-daemon.conf
			for service in messagebus avahi-daemon
			do
				chkconfig $service on
				service $service start
			done
			# this including mdns4 as the last entry allows reverse lookups to work
			sed -i "/^hosts:/chosts:      files mdns4_minimal [NOTFOUND=return] dns mdns4" /etc/nsswitch.conf
		}

		avahi_init=0
		[[ -d /opt/avahi-alias ]] || {
			echo "Setting up avahi cname support"
			avahi_home=$(getent passwd avahi | awk -F: '{print $6}')
			avahi_mount=$avahi_home/.local/lib/python2.6/site-packages
			site_packages=/opt/avahi-alias/site-packages
			git clone --recursive https://github.com/asharpe/avahi-alias.git /opt/avahi-alias && {
				cp /opt/avahi-alias/avahi-alias.upstart-sl6 /etc/init/avahi-alias.conf
				mkdir -p $site_packages/avahi
				ln -s /usr/lib/python2.6/site-packages/dbus $site_packages
				ln -s /usr/lib64/python2.6/site-packages/_dbus_bindings.so $site_packages
				curl -so $site_packages/avahi/__init__.py http://git.0pointer.net/avahi.git/plain/avahi-python/avahi/__init__.py
				mkdir -p /etc/avahi/alias.d $avahi_mount
				grep -q $site_packages /etc/fstab || {
					echo "$site_packages	$avahi_mount none bind,defaults" >> /etc/fstab
					mount $avahi_mount
					avahi_init=1
				}
			}
		}

		((avahi_init)) && {
			start avahi-alias
		}

		cat <<-EOF >&2
			To create an avahi cname, create a file in /etc/avahi/alias.d with one domain per line, then run:
			 	restart avahi-alias
		EOF

	EOSH


end


