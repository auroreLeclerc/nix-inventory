#!/usr/bin/env bash
source /etc/os-release
if [[ $(date +%s) -gt $(date -d "$SUPPORT_END" +%s) ]]; then
	cowsay -f dragon-and-cow "$PRETTY_NAME has reached EOL"
else
	echo "$NAME  $(nixos-version --json | jq -r '.nixosVersion') ${VERSION_CODENAME^} $(uname -a) !" | lolcat
	echo
	df -h -T -x tmpfs -x devtmpfs -x efivarfs
	echo
	w -s
	echo
	if [ -f /etc/systemd/system/nixos-upgrade.timer ]; then
		update_time=$(systemctl status nixos-upgrade.timer | grep 'Trigger:' | cut -d ";" -f 2)
		echo "NixOS Upgrade 󰚰$update_time"
	fi
	if [ -f /etc/systemd/system/nix-gc.timer ]; then
		clean_time=$(systemctl status nix-gc.timer | grep 'Trigger:' | cut -d ";" -f 2)
		echo "Nix Collect Garbage 🧹$clean_time"
	fi
	if [ -d ~/.local/share/containers/ ]; then
		update_time=$(systemctl --user status podman-auto-update.timer | grep 'Trigger:' | cut -d ";" -f 2)
		echo "Podman Update $update_time"
		containers=$(($(podman ps | wc -l) - 1))
		echo "Container(s)  Running : $containers"
	fi
	if [ -f /etc/systemd/system/zfs-mount.service ]; then
		result=''
		for pool in $(zpool list -H -o name); do
			health=$(zpool list -H -o health "$pool")
			result+="$pool "
			case $health in
				ONLINE)
					result+='󱘩'
				;;
				DEGRADED)
					result+='󱤢'
				;;
				FAULTED)
					result+='󱘵'
				;;
				OFFLINE)
					result+='󱘱'
				;;
				UNAVAIL|SUSPENDED)
					result+='󱤡'
				;;
				REMOVED)
					result+='󱘰'
				;;
			esac
			result+=' ; '
		done
		echo "ZFS : ${result::-2}"
	fi
	current_kernel=$(readlink /run/booted-system/kernel | grep -Eo 'linux-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+')
	new_kernel=$(readlink /nix/var/nix/profiles/system/kernel | grep -Eo 'linux-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+')
	if [[ $current_kernel != "$new_kernel" ]]; then
		echo
		echo "Reboot needed to use the new $new_kernel kernel !" | lolcat
	fi
fi
