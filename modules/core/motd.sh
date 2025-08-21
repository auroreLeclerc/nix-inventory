#!/usr/bin/env bash
source /etc/os-release
if [[ $(date +%s) -gt $(date -d "$SUPPORT_END" +%s) ]]; then
	cowsay -f dragon-and-cow "$PRETTY_NAME has reached EOL"
else
	function date_calculator() {
		local diff_sec=$(($(TZ='Europe/Paris' date -d "$1" +%s) - $(TZ='Europe/Paris' date +%s)))
		local days=$((diff_sec / 86400))
		local hours=$(((diff_sec % 86400) / 3600))
		local minutes=$(((diff_sec % 3600) / 60))
		echo "${days}jour(s) ${hours}heure(s) ${minutes}minute(s)"
	}
	echo "$NAME  $(nixos-version --json | jq -r '.nixosVersion') ${VERSION_CODENAME^} $(uname -a) !" | lolcat
	echo
	df -h -T -x tmpfs -x devtmpfs -x efivarfs
	echo
	w -s
	echo
	if [ -f /etc/systemd/system/nixos-upgrade.timer ]; then
		update_date=$(systemctl status nixos-upgrade.timer | grep 'Trigger:' | grep -Eo '\w{3} [[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2} [[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2} CE(S?)T')
		echo "Update 󰚰 dans $(date_calculator "$update_date")"
	fi
	if [ -f /etc/systemd/system/nix-gc.timer ]; then
		clean_date=$(systemctl status nix-gc.timer | grep 'Trigger:' | grep -Eo '\w{3} [[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2} [[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2} CE(S?)T')
		echo "Cleanup 🧹 dans $(date_calculator "$clean_date")"
	fi
	if [ -d ~/.local/share/containers/ ]; then
		podman=$(($(podman ps | wc -l) - 1))
		echo "$podman container(s) "
	fi
	if [ -f /etc/systemd/system/zfs-mount.service ]; then
		result=''
		for pool in $(zpool list -H -o name); do
			health=$(zpool list -H -o health "$pool")
			if [[ "$health" == "ONLINE" ]]; then
				result+="$pool 󱘩 ; "
			else
				result+="$pool 󱘤 ; "
			fi
		done
		echo "$result"
	fi
	current_kernel=$(readlink /run/booted-system/kernel | grep -Eo 'linux-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+')
	new_kernel=$(readlink /nix/var/nix/profiles/system/kernel | grep -Eo 'linux-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+')
	if [[ $current_kernel != "$new_kernel" ]]; then
		echo
		echo "Reboot needed to use the new $new_kernel kernel !" | lolcat
	fi
fi
