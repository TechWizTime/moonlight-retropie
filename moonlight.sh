#!/bin/bash
set -e # exit on error

# validate if root
if [ "$user" == "root" ]; then
	echo -e "This script isn't supposed to be run as root\nExiting..."
	exit 0
fi

#get current dir from this answer
#https://stackoverflow.com/a/630645
prg=$0
if [ ! -e "$prg" ]; then
  case $prg in
    (*/*) exit 1;;
    (*) prg=$(wich -v -- "$prg") || exit;;
  esac
fi
dir=$( cd -P -- "$(dirname -- "$prg")" && pwd -P ) || exit
prg=$dir/$(basename -- "$prg") || exit 
wd="$(dirname `printf '%s\n' $prg`)"
#echo $wd
user="`whoami`"
home_dir="$HOME"
arg="$1"
arg1="$2"
RELEASE=$(lsb_release -a | awk '/^Codename:/ {print $2}')

# add sources for moonlight
function add_sources {
	# $1 = jessie or stretch

	if grep -q "deb http://archive.itimmer.nl/raspbian/moonlight $RELEASE main" /etc/apt/sources.list; then
		echo -e "NOTE: Moonlight Source Exists - Skipping"
	else
		echo -e "Adding Moonlight to Sources List"
		echo "deb http://archive.itimmer.nl/raspbian/moonlight $RELEASE main" >> /etc/apt/sources.list
	fi
}

# fetch and install gpg keys
function install_gpg_keys {
	# $1 can be -f to force overwriting
	if [ -f ./itimmer.gpg ]; then
		echo -n "NOTE: GPG Key Exists - "
		if [ "$1" == '-f' ]; then
			echo -e "Overwriting"
			rm ./itimmer.gpg
		else
			echo -e "Skipping"
			return 0
		fi
	fi	

	wget http://archive.itimmer.nl/itimmer.gpg 
	echo "sudo apt-key add itimmer.gpg"
	sudo apt-key add itimmer.gpg 
	rm ./itimmer.gpg
}

# update system and install moonlight
function update_and_install_moonlight {
	# $1 -u to update and install and -i to just install moonlight
	case "$1" in
		-u) sudo apt-get update -y ;;
		-i) sudo apt-get install moonlight-embedded -y  ;;
		*) echo -e "Invalid"; return 1;;
	esac
}

# pair moonlight with steam pc
function pair_moonlight {
	echo -e "Once you have input your STEAM PC's IP Address below, you will be given a PIN"
	echo -e "Input this on the STEAM PC to pair with Moonlight. \n"
	read -p "Input STEAM PC's IP Address here :`echo $'\n> '`" ip
	sudo -u pi moonlight pair $ip 
}

#create steam menu
function create_menu {
	if [ -f "$home_dir"/.emulationstation/es_systems.cfg ]
	then
		echo -e "Removing Duplicate Systems File"
		rm "$home_dir"/.emulationstation/es_systems.cfg
	fi

	echo -e "Copying Systems Config File"
	cp /etc/emulationstation/es_systems.cfg "$home_dir"/.emulationstation/es_systems.cfg

	if grep -q "<platform>steam</platform>" "$home_dir"/.emulationstation/es_systems.cfg; then
		echo -e "NOTE: Steam Entry Exists - Skipping"
	else
		echo -e "Adding Steam to Systems"
		sed -i -e 's|</systemList>|  <system>\n    <name>steam</name>\n    <fullname>Steam</fullname>\n    <path>~/RetroPie/roms/moonlight</path>\n    <extension>.sh .SH</extension>\n    <command>bash %ROM%</command>\n    <platform>steam</platform>\n    <theme>steam</theme>\n  </system>\n</systemList>|g' "$home_dir"/.emulationstation/es_systems.cfg
	fi
}

#add steam launch scripts
function create_launch_scripts {
	echo -e "Create Script Folder"
	mkdir -p "$home_dir"/RetroPie/roms/moonlight

	if [ "$1" == '-f' ]; then
		echo -e "NOTE: Removing old scripts"
		remove_launch_scripts
	fi

	cd "$home_dir"/RetroPie/roms/moonlight

	echo -e "Create Scripts"
	if [ -f ./720p30fps.sh ]; then
		echo -e "NOTE: 720p30fps Exists - Skipping"
	else
		echo "#!/bin/bash" > 720p30fps.sh
		echo "moonlight stream -720 -fps 30 "$ip"" >>  720p30fps.sh
	fi

	if [ -f ./720p60fps.sh ]; then
		echo -e "NOTE: 720p60fps Exists - Skipping"
	else
		echo "#!/bin/bash" > 720p60fps.sh
		echo "moonlight stream -720 -fps 60 "$ip"" >>  720p60fps.sh
	fi

	if [ -f ./1080p30fps.sh ]; then
		echo -e "NOTE: 1080p30fps Exists - Skipping"
	else
		echo "#!/bin/bash" > 1080p30fps.sh
		echo "moonlight stream -1080 -fps 30 "$ip"" >>  1080p30fps.sh
	fi

	if [ -f ./1080p60fps.sh ]; then
		echo -e "NOTE: 1080p60fps Exists - Skipping"
	else
		echo "#!/bin/bash" > 1080p60fps.sh
		echo "moonlight stream -1080 -fps 60 "$ip"" >>  1080p60fps.sh
	fi

	echo -e "Make Scripts Executable"
	sudo chmod +x 720p30fps.sh 
	sudo chmod +x 720p60fps.sh
	sudo chmod +x 1080p30fps.sh
	sudo chmod +x 1080p60fps.sh

	cd "$wd"
}

#remove steam laucnh scripts
function remove_launch_scripts {
	cd "$home_dir"/RetroPie/roms/moonlight/
	[ "$(ls -A .)" ] && rm * || echo -n ""	
}

#define files permissions -- Not sure if this is really needed but I'll leave it here
function set_permissions {
	echo -e "Changing File Permissions"
	sudo chown -R pi:pi "$home_dir"/RetroPie/roms/moonlight/
	sudo chown pi:pi "$home_dir"/.emulationstation/es_systems.cfg
}

#change controller mapping -- currrently doesn't work
function map_controller {
	echo -e "\nWIP\n"
	return 0

	#possible solution
	#https://retropie.org.uk/forum/topic/11225/moonlight-no-mapping-available-for-dev-input-event2-030000005e040000a102000007010000

	if [ "$(ls -A $home_dir/RetroPie/roms/moonlight/)" ]; then
		mkdir -p "$home_dir"/.config/moonlight
		read -n 1 -s -p "Make sure your controller is plugged in and press anykey to continue"
		ls -l /dev/input/by-id
		echo -e "Type the device name (it's probably one of the eventX): "
		read -p "> " controller

		cp /dev/stdin  myfile.txt
		touch
		moonlight map -input /dev/input/"$controller" "$home_dir"/.config/moonlight/controller.map
		

		cd "$home_dir"/RetroPie/roms/moonlight/
		if [ -f ./720p30fps.sh ] && [ -z "`sed -n '/-mapping/p' ./720p30fps.sh`" ]; then
			sed -i "s/^moonlight.*/& -mapping \/home\/$user\/.config\/moonlight\/controller.map/" 720p30fps.sh
		fi

		if [ -f ./720p60fps.sh ] && [ -z "`sed -n '/-mapping/p' ./720p60fps.sh`" ]; then
			sed -i "s/^moonlight.*/& -mapping \/home\/$user\/.config\/moonlight\/controller.map/" 720p60fps.sh
		fi

		if [ -f ./1080p30fps.sh ] && [ -z "`sed -n '/-mapping/p' ./1080p30fps.sh`" ]; then
			sed -i "s/^moonlight.*/& -mapping \/home\/$user\/.config\/moonlight\/controller.map/" 1080p30fps.sh
		fi

		if [ -f ./1080p60fps.sh ] && [ -z "`sed -n '/-mapping/p' ./1080p60fps.sh`" ]; then
			sed -i "s/^moonlight.*/& -mapping \/home\/$user\/.config\/moonlight\/controller.map/" 1080p60fps.sh
		fi

		cd "$wd"
	else 
		echo -e "You need to generate your launch scripts first."
		return 0
	fi
}

#change default audio output
#could be updated to set subdevices, but i'm not sure how that works
function set_audio_output {
	if [ "$(ls -A $home_dir/RetroPie/roms/moonlight/)" ]; then

		if [ "$arg1" ]; then
			device="$arg1"
			subdevice="0"
		else
			echo -e "Choose your preferred audio output:"
			echo -e "Tip: Use aplay -l to see installed devices"
			echo -e "0 - Audio Jack"
			echo -e "1 - HDMI"
			echo -n "> "

			read device
			subdevice="0"
		fi

		audio_out="hw:$device,$subdevice"

		cd "$home_dir"/RetroPie/roms/moonlight/
		if [ -f ./720p30fps.sh ]; then
			if [ -z "`sed -n '/-audio/p' ./720p30fps.sh`" ]; then
				sed -i "s/^moonlight.*/& -audio hw:0,0/" 720p30fps.sh
			fi
			sed -i "s/hw:[[:digit:]],[[:digit:]]/$audio_out/" 720p30fps.sh
		fi

		if [ -f ./720p60fps.sh ]; then
			if [ -z "`sed -n '/-audio/p' ./720p60fps.sh`" ]; then
				sed -i "s/^moonlight.*/& -audio hw:0,0/" 720p60fps.sh
			fi
			sed -i "s/hw:[[:digit:]],[[:digit:]]/$audio_out/" 720p60fps.sh
		fi

		if [ -f ./1080p30fps.sh ]; then
			if [ -z "`sed -n '/-audio/p' ./1080p30fps.sh`" ]; then
				sed -i "s/^moonlight.*/& -audio hw:0,0/" 1080p30fps.sh
			fi
			sed -i "s/hw:[[:digit:]],[[:digit:]]/$audio_out/" 1080p30fps.sh
		fi

		if [ -f ./1080p60fps.sh ]; then
			if [ -z "`sed -n '/-audio/p' ./1080p60fps.sh`" ]; then
				sed -i "s/^moonlight.*/& -audio hw:0,0/" 1080p60fps.sh
			fi
			sed -i "s/hw:[[:digit:]],[[:digit:]]/$audio_out/" 1080p60fps.sh
		fi

		cd "$wd"
	else 
		echo -e "You need to generate your launch scripts first."
		return 1
	fi

	if [ "$arg1" ]; then
		return 1
	fi

}

#create menu entries for sound options
function sound_menu {
	config_menu
	echo "$wd/moonlight.sh 7 0" > "$home_dir"/RetroPie/roms/moonlight/audio_jack.sh
	echo "$wd/moonlight.sh 7 1" > "$home_dir"/RetroPie/roms/moonlight/hdmi.sh
	
	echo -e "Make executable"
	sudo chmod +x "$home_dir"/RetroPie/roms/moonlight/audio_jack.sh
	sudo chmod +x "$home_dir"/RetroPie/roms/moonlight/hdmi.sh
}

#update this script
function update_script {
	cd "$wd"	
	if [ -f ./moonlight.sh ]
	then
		echo -e "Removing Script"
		rm ./moonlight.sh
	fi

	#wget https://techwiztime.com/moonlight.sh --no-check
	wget https://raw.githubusercontent.com/Klubas/moonlight-retropie/master/moonlight.sh --no-check
	if [ ! -x ./moonlight ]; then
		echo "Making it executable"
		sudo chmod +x "$wd"/moonlight.sh
	fi
}

#restart this script
function restart_script {
	if [ -z $arg ]; then 
		"$wd"/moonlight.sh
	fi
}

#add this script to emulation EmulationStation steam menu
function config_menu {
	if [ -f "$home_dir"/RetroPie/roms/moonlight/moonlight.sh ]; then
		echo -e "Do you wish to remove the configuration menu? (Y)es / (N)o / (0)verwite"
		echo -n "> "
		read option
		case "$option" in
			y|Y) rm "$home_dir"/RetroPie/roms/moonlight/moonlight.sh; return 0 ;;
			n|N) return 0 ;;
			o|O) rm "$home_dir"/RetroPie/roms/moonlight/moonlight.sh;;
			*) echo -e "Invalid."; return 0 ;;
		esac
	fi
	
	ln $wd/moonlight.sh "$home_dir"/RetroPie/roms/moonlight/moonlight.sh
}

#you can call the script passing one of the menu options as the first arg
if [ $# -eq 0 ]; then
	echo -e "\n****************************************************************"
	echo -e "Welcome to the Moonlight Installer Script for RetroPie v17.10.07"
	echo -e "****************************************************************\n"
	echo -e "Select an option:"
	echo -e " * 1: Install Moonlight, Pair, Install Scripts, Install Menus"
	echo -e " * 2: Install Launch Scripts"
	echo -e " * 3: Remove Launch Scripts"
	echo -e " * 4: Re Pair Moonlight with PC"
	echo -e " * 5: Refresh SYSTEMS Config File"
	echo -e " * 6: Update This Script"
	echo -e " * 7: Audio Output options"
	echo -e " * 8: Controller Mapping"
	echo -e " * 9: Put this Script on the EmulationStation menu"
	echo -e " * 0: Exit"
	echo -n " > "
	read NUM
else
	NUM=$arg
fi

case "$NUM" in
	1)
		echo -e "\nAdd Moonlight to Sources List"
		echo -e "****************************************\n"
		add_sources

		echo -e "\nFetch and install the GPG key"
		echo -e "****************************************\n"
		install_gpg_keys -f

		echo -e "\nUpdate System and install moonlight"
		echo -e "**************************\n"
		update_and_install_moonlight -u
		update_and_install_moonlight -i

		echo -e "\nPair Moonlight with PC"
		echo -e "**********************************\n"
		pair_moonlight

		echo -e "\nCreate STEAM Menu for RetroPie"
		echo -e "*****************************************\n"
		create_menu

		echo -e "\nCreate 1080p+720p Launch Scripts for RetroPie"
		echo -e "**********************************************************\n"
		create_launch_scripts

		echo -e "\nMaking Everything PI Again :)"
		echo -e "******************************************\n"
		set_permissions

		echo -e "Everything should now be installed and setup correctly."
		echo -e "To be safe, it's recommended that you perform a reboot now."
		echo -e "\nIf you don't want to reboot now, press N\n"

		read -p "Reboot Now (y/n)? " choice
		case "$choice" in
		  y|Y ) shutdown -r now;;
		  n|N ) restart_script;;
		  * ) echo "invalid";;
		esac
	;;

	2)
		echo -e "\nCreate 1080p + 720p Launch Scripts for RetroPie"
		echo -e "***********************************************\n"
		create_launch_scripts
		echo -e "\n**** 1080p + 720p Launch Scripts Creation Complete!!!! ****"
		restart_script
	;;

	3)
		echo -e "\nRemove All Steam Launch Scripts"
		echo -e "***********************************\n"
		remove_launch_scripts
		echo -e "\n**** Launch Script Removal Complete!!! ****"
		restart_script
	;;

	4)
		echo -e "\nRe-Pair Moonlight with another PC"
		echo -e "*********************************\n"
		pair_moonlight
		echo -e "\n**** Re-Pair Process Complete!!!! ****"
		restart_script
	;;
	
	5)
		echo -e "\nRefresh RetroPie Systems File"
		echo -e "*****************************\n"
		create_menu
		echo -e "\n**** Refreshing Retropie Systems File Complete!!!! ****"
		restart_script
	;;

	6)
		echo -e "\nUpdate This Script"
		echo -e "*****************************\n"
		update_script
		restart_script
	;;
	
	7)
		echo -e "\nChange default audio output"
		echo -e "*****************************\n"
		set_audio_output "$arg2"
		echo -e "\nCreate shortcuts in EmulationStation Steam menu? (y/n)"
		read -p "> " opt 
		case $opt in
			y|Y)
				sound_menu
				echo -e "Menu entries created" ;;
			*) 
				echo -e "No";;
		esac
		restart_script
	;;
    
	8)
		echo -e "\nMapping the controller"
		echo -e "**********************************\n"
		map_controller
		restart_script
	;;

	9) 
		echo -e "\nCreate menu entry"
		echo -e "**********************************\n"
		echo -e "NOTE: You won't be able to interact with this script using a controller!"
		config_menu
		restart_script
	;;

    0) exit 1;;
	*) echo "INVALID NUMBER!" ;;
esac

exit 0