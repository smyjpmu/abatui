#!/bin/bash
	GNUGPL="\
this script is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

this script is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this script.  If not, see <https://www.gnu.org/licenses/>.
"
wizard () {
# GNU G.P.L v3
	gnugpl () {
		whiptail --msgbox "$GNUGPL" --title "GNU General Public License v3" 18 78
	}
	gnugpl

# Target drive
	drive () {
		drive=$(whiptail --inputbox "/dev/sd* (replace the * with the drive letter) $(lsblk)" 20 60 /dev/sd\* --title "What drive do I install onto?" 3>&1 1>&2 2>&3)
		if [ "$exitstatus" == "1" ]; then
			exit
		fi
	}
	drive

# Nvme drive
	nvme () {
		nvme=$(whiptail --menu "" 8 60 2 --title "Do I have an Nvme ssd?" 3>&1 1>&2 2>&3 "false" "I don't have an Nvme SSD." "true" "I have an Nvme SSD.")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			drive
		fi
	}
	nvme

# Erase drive
	erase () {
		encrypt=$(whiptail --menu "" 8 60 2 --title "Do I rewrite/erase my drive with zeros?" 3>&1 1>&2 2>&3 "false" "I don't want to erase my drive." "true" "I want to erase my drive.")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			nvme
		fi
	}
	erase

# Encrypt drive
	encrypt () {
		encrypt=$(whiptail --menu "" 8 60 2 --title "Do I encrypt my drive?" 3>&1 1>&2 2>&3 "false" "I don't want to encrypt my drive." "true" "I want to encrypt my drive.")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			erase
		fi
	}
	encrypt

# File System
	filesystem () {
		filesystem=$(whiptail --menu "" 8 60 2 --title "What filesystem do I want?" 3>&1 1>&2 2>&3 "ext4" "Recommended and is nearly indestructible." "btrfs" "Use only if you need certain features.")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			encrypt
		fi
	}
	filesystem

# Bootloader ID
	bootloader_id () {
		bootloader_id=$(whiptail --inputbox "" 8 60 Arch\ Linux --title "What bootloader ID do I want?" 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			filesystem
		fi
	}
	bootloader_id

# Hostname
	hostname () {
		hostname=$(whiptail --inputbox "" 8 60 archlinux --title "What hostname do I want?" 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			bootloader_id
		fi
	}
	hostname

# Username
	username () {
		username=$(whiptail --inputbox "" 8 60 noname --title "What's my username?" 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			hostname
		fi
	}
	username

# User Password
	user_pwd () {
		while [ "$user_pwd" != "$user_pwd2" ]; do
	  	user_pwd=$(whiptail --passwordbox "" 8 60 --title "What's the _sTR0nG_ password for ${username}?" 3>&1 1>&2 2>&3)
	  	user_pwd2=$(whiptail --passwordbox "" 8 60 --title "Re-enter the _sTR0nG_ password for ${username}." 3>&1 1>&2 2>&3)
			whiptail --msgbox "Passowrds did not match, please try again." --title "They don't match!" 8 60
		done
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			username
		fi
	}
	user_pwd

# Root Password
	root_pwd () {
		while [ "$root_pwd" != "$root_pwd2" ]; do
			root_pwd=$(whiptail --passwordbox "" 8 60 --title "What's the _sTR0nG_ password for root?" 3>&1 1>&2 2>&3)
			root_pwd2=$(whiptail --passwordbox "" 8 60 --title "Re-enter the _sTR0nG_ password for root" 3>&1 1>&2 2>&3)
			whiptail --msgbox "Passowrds did not match, please try again." --title "They don't match!" 8 60
		done
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			user_pwd
		fi
	}
	root_pwd

# Country
	country () {
		country=$(whiptail --inputbox "Examples: US, CA, DE..." 8 60 --title "What's my country code?" 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			root_pwd
		fi
	}
	country

# Timezone
 timezone () {
		timezone=""
		choosing_timezone=true
    	while [ $choosing_timezone ]; do
        	if [ -d "/usr/share/zoneinfo"$(if [ -n $timezone ]; then echo "/$timezone/"; fi) ]; then
             	tmp_timezone=$(whiptail --noitem --title "What timezone am I in?" --menu "" 30 40 22 $(for ZONE in $(find /usr/share/zoneinfo/$(if [ -n "$timezone" ]; then echo "$timezone/"; fi) -maxdepth 1 \
             	$([ -z "$timezone" ] && echo "-type d") -not -name right -not -name posix -not -name Etc -not -wholename "/usr/share/zoneinfo/$timezone/" -not -wholename "/usr/share/zoneinfo/$timezone" 2>/dev/null | sed "s#/usr/share/zoneinfo/$timezone##" | sed "s#/##"); do
                 	echo "$ZONE $ZONE"
             	done) 3>&1 1>&2 2>&3)
             	if [ -z $timezone ]; then
                 	timezone="$tmp_timezone"
             	else
                 	timezone=$timezone/$tmp_timezone
             	fi
        	else
            	choosing_timezone=false
            	break
        	fi
    	done
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			country
		fi
	}
	timezone

# language
	language () {
    language=$(eval 'whiptail --radiolist "Default: en_US.UTF-8 UTF-8" 40 60 30 --title "What language do I use?" 3>&1 1>&2 2>&3' "$(sed -r '/^# /d;/^#$/d;s/#//;s/  //;s/.*/ "&/;s/$/" locale OFF&/;s/"en_US.UTF-8 UTF-8" locale OFF/"en_US.UTF-8 UTF-8" locale ON/' /etc/locale.gen | tr -d "\n")")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			timezone
		fi
	}
	language

# Keymap
	keymap () {
		keymap=$(eval 'whiptail --radiolist "Default: us" 40 60 30 --title "What keymap do I use?" 3>&1 1>&2 2>&3' "$(find /usr/share/kbd -name '*.map.gz' -type f -printf '%f\n' | cut -d. -f1 | sort | sed -r 's/.*/ "&/;s/$/" keymap OFF&/;s/"us" keymap OFF/"us" keymap ON/g' | tr -d "\n")")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			language
		fi
	}
	keymap

# desktop environment
	desktop_env () {
		desktop_env=$(whiptail --menu "" 18 80 11 --title "What desktop environment do I want?" 3>&1 1>&2 2>&3 "nodeorwm" "Comes with nothing and is nothing." "budgie" "Modern design, focuses on simplicity and elegance." "cinnamon" "Strives to provide a traditional user experience." "gnome" "An attractive and intuitive desktop." "kde" "Modern and familiar working environment." "lxde" "Strives to be less CPU and RAM intensive." "lxqt" "Lightweight, modular, blazing-fast and user-friendly." "mate" " Intuitive and attractive desktop using traditional metaphors." "xfce" "Traditional UNIX philosophy of modularity and re-usability." "i3-gaps" "Primarily targeted at developers and advanced users" "sway" "Drop-in replacement of i3/i3-gaps for Wayland")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			keymap
		fi
	}
	desktop_env

# Display manager
	display_mgr () {
		display_mgr=$(whiptail --menu "" 13 50 7 --title "What display manager do I want?" 3>&1 1>&2 2>&3 "nodm" "Comes with nothing and is nothing." "gdm" "Recommended for Budgie & Gnome." "lightdm" "Recommended for XFCE." "lxdm" "Recommended for LXDE." "sddm" "Recommended for KDE & LXQT." "ly" "TUI based" "tty" "CLI based")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			desktop_env
		fi
	}
	display_mgr

# Multilib
	multilib () {
		multilib=$(whiptail --menu "" 8 60 2 --title "Do I want the Multilib repository?" 3>&1 1>&2 2>&3 "false" "I DO NOT want the Multilib repository." "true" "I want the Multilib repository.")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			display_mgr
		fi
	}
	multilib

# BlackArch
	blackarch () {
		blackarch=$(whiptail --menu "" 8 60 2 --title "Do I want the BlackArch repository?" 3>&1 1>&2 2>&3 "false" "I DO NOT want the BlackArch repository." "true" "I want the BlackArch repository.")
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			multilib
		fi
	}
	blackarch

# BlackArch tools
	blackarch_tools () {
		if $blackarch; then
			blackarch_tools=$(whiptail --menu "" 8 60 2 --title "Do I want the 2000+ BlackArch tools" 3>&1 1>&2 2>&3 "false" "DO NOT install BlackArch tools." "true" "Install BlackArch tools. (~50GB)")
		fi
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			blackarch
		fi
	}
	blackarch_tools

# Custom packages
	custom_pkg () {
		custom_pkg=$(whiptail --separate-output --checklist "" 30 50 22 --title "What custom packages do I want?" 3>&1 1>&2 2>&3 "firefox" "Web Browser" ON "atom" "IDE" ON "weechat" "IRC client" ON "libreoffice" "Office suite" ON "tor" "proxy" ON "deluge" "torrent manager" ON "gimp" "image manipulator" ON "audacity" "audio editor" ON "blender" "3d editor" ON "darktable" "photo editor" ON "inkscape" "vector editor" ON "krita" "drawing editor" ON "steam" "Game client" OFF "playonlinux" "wine manager" OFF "lutris" "wine manager" OFF)
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			blackarch_tools
		fi
	}
	custom_pkg

# Other custom packages
	other_custom_pkg () {
		other_custom_pkg=$(whiptail --inputbox "Example: package package1 package2 package3" 8 60 --title "Do I want any other custom packages?" 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			custom_pkg
		fi
	}
	other_custom_pkg

# AUR custom packages
	aur_custom_pkg () {
		aur_custom_pkg=$(whiptail --separate-output --checklist "" 30 50 22 --title "What AUR custom packages do I want?" 3>&1 1>&2 2>&3 "discord" "discord" OFF "spotify" "spotify" OFF "polybar" "polybar" OFF)
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			other_custom_pkg
		fi
	}
	aur_custom_pkg

# AUR other custom packages
	aur_other_custom_pkg () {
		aur_other_custom_pkg=$(whiptail --inputbox "Example: aur-package aur-package1 aur-package2 aur-package3" 8 60 --title "Do I want any other AUR custom packages?" 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ "$exitstatus" == "1" ]; then
			aur_custom_pkg
		fi
	}
	aur_other_custom_pkg
}
wizard

# Confirmation
	whiptail --yesno "Did you make any mistake during the wizard? You can still go back by selecting \"yes\"" 8 60 --title "Did I make mistakes?" 3>&1 1>&2 2>&3
	exitstatus=$?
	if [ "$exitstatus" == "0" ]; then
		wizard
	fi

# Desktop environment
	case $desktop_env in
		"budgie" )
			desktop_env_pkg="budgie-desktop budgie-extras baobab cheese eog epiphany evince file-roller gedit gnome-backgrounds gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-color-manager gnome-contacts gnome-control-center gnome-dictionary gnome-disk-utility gnome-documents gnome-font-viewer gnome-getting-started-docs gnome-keyring gnome-logs gnome-maps gnome-menus gnome-music gnome-photos gnome-remote-desktop gnome-screenshot gnome-session gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-themes-extra gnome-todo gnome-user-docs gnome-user-share gnome-video-effects grilo-plugins gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb mousetweaks mutter nautilus networkmanager orca rygel sushi totem tracker tracker-miners vino xdg-user-dirs-gtk yelp gnome-boxes gnome-software simple-scan";;
		"cinnamon" )
			desktop_env_pkg="cinnamon";;
		"gnome" )
			desktop_env_pkg="baobab cheese eog epiphany evince file-roller gedit gnome-backgrounds gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-color-manager gnome-contacts gnome-control-center gnome-dictionary gnome-disk-utility gnome-documents gnome-font-viewer gnome-getting-started-docs gnome-keyring gnome-logs gnome-maps gnome-menus gnome-music gnome-photos gnome-remote-desktop gnome-screenshot gnome-session gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-themes-extra gnome-todo gnome-user-docs gnome-user-share gnome-video-effects grilo-plugins gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb mousetweaks mutter nautilus networkmanager orca rygel sushi totem tracker tracker-miners vino xdg-user-dirs-gtk yelp gnome-boxes gnome-software simple-scan accerciser brasero dconf-editor devhelp evolution five-or-more four-in-a-row gnome-builder gnome-chess gnome-devel-docs gnome-klotski gnome-mahjongg gnome-mines gnome-nettool gnome-nibbles gnome-robots gnome-sound-recorder gnome-sudoku gnome-taquin gnome-tetravex gnome-tweaks gnome-weather hitori iagno lightsoff nautilus-sendto polari quadrapassel swell-foop sysprof tali gedit-code-assistance gnome-code-assistance gnome-multi-writer gnome-recipes gnome-usage";;
		"kde" )
			desktop_env_pkg="plasma-meta kde-applications-meta";;
		"lxde" )
			desktop_env_pkg="gpicview lxappearance lxappearance-obconf lxde-common lxde-icon-theme lxhotkey lxinput lxlauncher lxmusic lxpanel lxrandr lxsession lxtask lxterminal openbox pcmanfm";;
		"lxqt" )
			desktop_env_pkg="lximage-qt lxqt-about lxqt-admin lxqt-config lxqt-globalkeys lxqt-notificationd lxqt-openssh-askpass lxqt-panel lxqt-policykit lxqt-powermanagement lxqt-qtplugin lxqt-runner lxqt-session lxqt-sudo lxqt-themes obconf-qt openbox pcmanfm-qt qterminal";;
		"mate" )
			desktop_env_pkg="caja marco mate-backgrounds mate-control-center mate-desktop mate-icon-theme mate-menus mate-notification-daemon mate-panel mate-polkit mate-session-manager mate-settings-daemon mate-themes mate-user-guide atril caja-image-converter caja-open-terminal caja-sendto caja-share caja-wallpaper caja-xattr-tags engrampa eom mate-applets mate-calc mate-icon-theme-faenza mate-media mate-netbook mate-power-manager mate-screensaver mate-sensors-applet mate-system-monitor mate-terminal mate-user-share mate-utils mozo pluma";;
		"xfce" )
			desktop_env_pkg="exo garcon gtk-xfce-engine thunar thunar-volman tumbler xfce4-appfinder xfce4-panel xfce4-power-manager xfce4-session xfce4-settings xfce4-terminal xfconf xfdesktop xfwm4 xfwm4-themes mousepad orage thunar-archive-plugin thunar-media-tags-plugin xfburn xfce4-artwork xfce4-battery-plugin xfce4-clipman-plugin xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-datetime-plugin xfce4-dict xfce4-diskperf-plugin xfce4-eyes-plugin xfce4-fsguard-plugin xfce4-genmon-plugin xfce4-mailwatch-plugin xfce4-mount-plugin xfce4-mpc-plugin xfce4-netload-plugin xfce4-notes-plugin xfce4-notifyd xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-sensors-plugin xfce4-smartbookmark-plugin xfce4-systemload-plugin xfce4-taskmanager xfce4-time-out-plugin xfce4-timer-plugin xfce4-verve-plugin xfce4-wavelan-plugin xfce4-weather-plugin xfce4-xkb-plugin parole ristretto xfce4-whiskermenu-plugin";;
		"i3-gaps" )
			desktop_env_pkg="i3-gaps rofi rxvt-unicode ranger mc pcurses neofetch cmus calcurse bc maim xclip xsel";;
		"sway" )
			desktop_env_pkg="sway rofi rxvt-unicode ranger mc pcurses neofetch cmus calcurse bc maim xclip xsel";;
		"nodeorwm" )
			desktop_env_pkg="";;
	esac

# Display manager
	case $display_mgr in
		"nodm" )
			display_mgr_pkg=""
			aur_display_mgr_pkg="";;
		"gdm" )
			display_mgr_pkg="gdm"
			aur_display_mgr_pkg="";;
		"lightdm" )
			display_mgr_pkg="lightdm lightdm-gtk-greeter"
			aur_display_mgr_pkg="";;
		"lxdm" )
			display_mgr_pkg="lxdm"
			aur_display_mgr_pkg="";;
		"sddm" )
			display_mgr_pkg="sddm"
			aur_display_mgr_pkg="";;
		"ly" )
			aur_display_mgr_pkg="ly-git"
			display_mgr_pkg="";;
	esac

# Nvidia (i)GPU
	if $(lspci | grep -i "VGA compatible controller: NVIDIA Corporation" > /dev/null 2>&1); then
		echo "nVIDIA (i)GPU found, drivers will be installed"
		nvidia_pkg="nvidia nvidia-utils nvidia-settings"
	else
		nvidia_pkg=""
	fi

# AMD (i)GPU
	if $(lspci | grep -i "VGA compatible controller: Advanced Micro Devices" > /dev/null 2>&1); then
		echo "AMD (i)GPU found, drivers will be installed"
		amd_pkg="xf86-video-amdgpu vulkan-radeon libva-mesa-driver"
	else
		amd_pkg=""
	fi

# Packages
	BASE="bash bzip2 coreutils cryptsetup device-mapper dhcpcd diffutils e2fsprogs file filesystem findutils gawk gcc-libs gettext glibc grep gzip inetutils iproute2 iputils jfsutils less licenses linux logrotate lvm2 man-db man-pages mdadm nano netctl pacman pciutils perl procps-ng psmisc reiserfsprogs s-nail sed shadow sysfsutils systemd-sysvcompat tar texinfo usbutils util-linux vi which xfsprogs"
	BASE_DEVEL="autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman patch pkgconf sed sudo systemd texinfo util-linux which"
	pkgs="$BASE $BASE_DEVEL $desktop_env_pkg $display_mgr_pkg $nvidia_pkg $amd_pkg $custom_pkg $other_custom_pkg $blackarch_pkg linux-headers mesa xorg-server networkmanager network-manager-applet grub efibootmgr go unzip p7zip unrar curl wget git pulseaudio vlc zsh openssh vim openvpn networkmanager-openvpn arandr udiskie ntp"
	aur_pkg="$aur_desktop_env_pkg $aur_display_mgr_pkg $aur_custom_pkg $aur_other_custom_pkg"

# unmounting drives
	echo "-==Unmounting Drives==-"
	if $nvme; then
		umount ${drive}p1 /mnt/boot
		umount ${drive}p2 /mnt/
	else
		umount ${drive}1 /mnt/boot
		umount ${drive}2 /mnt/
	fi

# Erasing drives
	if $erase; then
		echo "-==Erasing Drives==-"
		dd if=/dev/zero of=$drive bs=1M status=progress
	fi

# installing arch
	echo "-==Starting Arch Installation==-"
	timedatectl set-ntp true
	echo "-==Checking If System Is Capeable Of EFI==-"
	if ls /sys/firmware/efi/efivars > /dev/null 2>&1; then
		efi=true
	else
		efi=false
	fi
	echo "-==Checking If $drive Is An SSD==-"
	if [ "$(cat /sys/block/$(echo $drive | cut -d'/' -f3)/queue/rotational)" = "0" ]; then
		ssd=true
		echo "-==$drive Is An SSD, Trim Will Be Enabled For Cryptsetup==-"
	fi
	echo "-==Formatting Drives/Partitions==-"
	sgdisk -og $drive
	if $efi; then
		sgdisk -n 1:0:+512M -c 1:"EFI" -t 1:ef00 $drive
	fi
	system_partition=$(if $efi; then echo 2; else echo 1; fi)
	sgdisk -n $system_partition:0:0 -c $system_partition:"System" -t $system_partition:8300 $drive
	if $nvme; then
		if $efi; then
			mkfs.fat -F32 ${drive}p1
		fi
		if $encrypt; then
			cryptsetup -y -v luksFormat --type luks2 ${drive}p$system_partition
			cryptsetup open $(if $ssd; then echo "--allow-discards"; fi) ${drive}p$system_partition cryptroot
			mkfs.$filesystem /dev/mapper/cryptroot
		else
			mkfs.$filesystem ${drive}p$system_partition
		fi
	else
		if $efi; then
			mkfs.fat -F32 ${drive}1
		fi
		if $encrypt; then
			cryptsetup -y -v luksFormat --type luks2 ${drive}2
			cryptsetup open $(if $ssd; then echo "--allow-discards"; fi) $drive$system_partition cryptroot
			mkfs.$filesystem /dev/mapper/cryptroot
		else
			mkfs.$filesystem $drive$system_partition
		fi
	fi
	sgdisk -p $drive
	echo "-==Mouting Formatted Drives==-"
	if $encrypt; then
		mount /dev/mapper/cryptroot /mnt
	else
		if $nvme; then
				mount ${drive}p$system_partition /mnt/
		else
			mount $drive$system_partition /mnt/
		fi
	fi
	if $efi; then
		mkdir /mnt/boot/
		if $nvme; then
			mount ${drive}p1 /mnt/boot
		else
			mount ${drive}1 /mnt/boot
		fi
	fi

# Encrypt drive
	if $encrypt; then
		echo "-==configuring mkinitcpio.conf and grub config for encryption==-"
		sed -i "s/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)/" /mnt/etc/mkinitcpio.conf
		sed -ir "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"([^\s\s]*)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 cryptdevice=UUID=device-UUID:cryptroot$(if $ssd; then echo ":allow-discards"; fi) root=\/dev\/mapper\/cryptroot\"/" /mnt/etc/default/grub
	fi

# Add user
	echo "-==Adding Normal User==-"
	arch-chroot /mnt useradd -m -g users -G wheel -s /bin/bash $username
	echo "root:$root_pwd" | chpasswd -R /mnt
	echo "$username:$user_pwd" | chpasswd -R /mnt
	arch-chroot /mnt echo "$username ALL=(ALL) ALL" >> /etc/sudoers
	mkdir /mnt/home/${username}/Documents
	mkdir /mnt/home/${username}/Downloads
	mkdir /mnt/home/${username}/Music
	mkdir /mnt/home/${username}/Pictures
	mkdir /mnt/home/${username}/Videos
	mkdir /mnt/home/${username}/GitHub
	if [ "$desktop_env" != "i3-gaps" -o "$desktop_env" != "sway" ]; then
		mkdir /mnt/home/${username}/Desktop
	fi

# Ranking mirrors
	echo "-==installing neccesarry packages to rank mirrors==-"
	pacman -Sy
	pacman -S --noconfirm pacman-contrib
	echo "-==backing up old mirrorlist==-"
	cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
	echo "-==creating list of 5 fastest Mirrors for ${country}this might take a bit==-"
	curl -s "https://www.archlinux.org/mirrorlist/?country=${country}&protocol=https&use_mirror_status=on" | sed -e 's/^#S/S/' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist
	echo "-==New Mirrorlist Created==-"

# Enabling multilib repo
	if $multilib; then
		echo "[community]" >> /mnt/etc/pacman.conf
		echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf
	fi

# Installing blackarch
	if $blackarch; then
		echo "-==Adding BlackArch Repository==-"
		arch-chroot /mnt/home/${username}/Downloads curl -O https://blackarch.org/strap.sh
		arch-chroot /mnt/home/${username}/Downloads chmod +x strap.sh
		arch-chroot /mnt/home/${username}/Downloads ./strap.sh
		if $blackarch_tools; then
			blackarch_pkg="blackarch"
		else
			blackarch_pkg=""
		fi
	fi

# Install packages
	echo "-==Installing Packages==-"
	if [ "$desktop_env" == "KDE" -a  "$display_mgr" == "$sddm" ]; then
  	pacstrap /mnt $pkgs sddm-kcm
	else
		pacstrap /mnt $pkgs
	fi

# Installing yay
	echo "-==Installing Yay==-"
	git clone https://aur.archlinux.org/yay.git /mnt/home/${username}/GitHub/
	arch-chroot /mnt/home/${username}/GitHub/yay/ makepkg -si
	if [ "$aur_pkg" != "" ]; then
		echo "-==Installing AUR Packages==-"
		arch-chroot /mnt su $username -c yes $user_pwd | yay -S $aur_pkg
	fi

# Installing Oh-My-ZSH
	echo "-==Installing Oh-My-ZSH==-"
	umask g-w,o-w
	env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git /mnt/home/${username}/.oh-my-zsh
	cp /mnt/home/${username}/.oh-my-zsh/templates/zshrc.zsh-template /mnt/home/${username}/.zshrc
	arch-chroot /mnt sed "/^export ZSH=/ c\ export ZSH=\"/mnt/home/${username}/.oh-my-zsh\"" ~/.zshrc > ~/.zshrc-omztemp
	mv -f ~/.zshrc-omztemp ~/.zshrc
	yes $user_pwd | chsh -s $(grep /zsh$ /etc/shells | tail -1)

# Generate fstab
	echo "-==Generating FS Tab==-"
	genfstab -U /mnt >> /mnt/etc/fstab

# Configure timezone
	echo "-==Configuring Time Zone==-"
	arch-chroot /mnt ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
	arch-chroot /mnt hwclock --systohc

# Configure locale
	echo "-==Configuring Locale==-"
	echo "$language" >> /mnt/etc/locale.gen
	arch-chroot /mnt locale-gen
	echo "LANG=$(echo $language | cut -d' ' -f1)" >> /mnt/etc/locale.conf
	echo "KEYMAP=$keymap" >> /mnt/etc/vconsole.conf

# Set hostname
	echo "-==Setting Hostname==-"
	echo "$hostname" > /mnt/etc/hostname
	echo "127.0.0.1 localhost $hostname" >> /mnt/etc/hosts

# Install grub
	echo "-==Installing GRUB==-"
	arch-chroot /mnt mkinitcpio -p linux
	arch-chroot /mnt grub-install --recheck $(if $efi; then echo "--target=x86_64-efi --efi-directory=/boot --bootloader-id=$bootloader_id"; else echo "--target=i386-pc $drive"; fi)
	git clone https://github.com/fghibellini/arch-silence.git /mnt/home/${username}/GitHub/
	cp -r /mnt/home/${username}/GitHub/arch-silence/theme /mnt/boot/grub/themes/arch-silence
	echo "GRUB_THEME="/boot/grub/themes/arch-silence/theme.txt"" >> /mnt/etc/default/grub
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
	echo "-==Enabling Services==-"
	arch-chroot /mnt systemctl enable NetworkManager
	if [ "$display_mgr" != "nodm" -o "$display_mgr" != "tty" ]; then
		arch-chroot /mnt systemctl enable $display_mgr
	fi
	arch-chroot /mnt systemctl enable ntpd
	if echo $custom_pkg | grep -q 'tor'; then
	   arch-chroot /mnt systemctl enable tor
	fi


echo "-==Arch Is Ready==-"
