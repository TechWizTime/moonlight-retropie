#!/bin/bash

set -e # exit on error

wd="`pwd`"
home_dir="/home/pi"

function add_sources {
	# $1 = jessie or stretch
	if grep -q "deb http://archive.itimmer.nl/raspbian/moonlight "$1" main" /etc/apt/sources.list; then
		echo -e "NOTE: Moonlight Source Exists - Skipping"
	else
		echo -e "Adding Moonlight to Sources List"
		echo "deb http://archive.itimmer.nl/raspbian/moonlight "$1" main" >> /etc/apt/sources.list
	fi
}

function install_gpg_keys {
	# $1 can be -f to force overwriting
	if [ -f "$home_dir"/itimmer.gpg ]; then
		echo -n "NOTE: GPG Key Exists - "
		if [ "$1" == '-f' ]; then
			echo -e "Skipping"
			return 0
		else
			echo -e "Overwriting"
		fi
	fi	

	wget http://archive.itimmer.nl/itimmer.gpg 
	chown pi:pi "$home_dir"/itimmer.gpg 
	apt-key add itimmer.gpg 

}

function update_and_install_moonlight {
	# $1 -u to update and install and -i to just install moonlight
	error=''
	case "$1" in
		'-u') apt-get update -y ;;&
		'-i') apt-get install moonlight-embedded -y  ;;
		*) echo -e "Invalid"; return 1;;
	esac
}

function pair_moonlight {
	echo -e "Once you have input your STEAM PC's IP Address below, you will be given a PIN"
	echo -e "Input this on the STEAM PC to pair with Moonlight. \n"
	read -p "Input STEAM PC's IP Address here :`echo $'\n> '`" ip
	sudo -u pi moonlight pair $ip 
}

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
		sudo sed -i -e 's|</systemList>|  <system>\n    <name>steam</name>\n    <fullname>Steam</fullname>\n    <path>~/RetroPie/roms/moonlight</path>\n    <extension>.sh .SH</extension>\n    <command>bash %ROM%</command>\n    <platform>steam</platform>\n    <theme>steam</theme>\n  </system>\n</systemList>|g' "$home_dir"/.emulationstation/es_systems.cfg
	fi
}

function create_launch_scripts {
	echo -e "Create Script Folder"
	mkdir -p "$home_dir"/RetroPie/roms/moonlight
	cd "$home_dir"/RetroPie/roms/moonlight

	if [ "$1" == '-f' ]; then
		echo -e "NOTE: Removing old scripts"
		remove_launch_scripts
	fi

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
	chmod +x 720p30fps.sh 
	chmod +x 720p60fps.sh
	chmod +x 1080p30fps.sh
	chmod +x 1080p60fps.sh

	cd "$wd"
}

function remove_launch_scripts {
	cd "$home_dir"/RetroPie/roms/moonlight
	rm *
	cd "$wd"
}

function set_permissions {
	echo -e "Changing File Permissions"
	chown -R pi:pi "$home_dir"/RetroPie/roms/moonlight/
	chown pi:pi "$home_dir"/.emulationstation/es_systems.cfg
}

function update_script {
	if [ -f "$wd"/moonlight.sh ]
	then
		echo -e "Removing Script"
		rm "$wd"/moonlight.sh
	fi
	#wget https://techwiztime.com/moonlight.sh --no-check
	wget https://raw.githubusercontent.com/Klubas/moonlight-retropie/master/moonlight.sh --no-check
	chown pi:pi "$wd"/moonlight.sh
	chmod +x "$wd"/moonlight.sh
}

function restart_script {
	cd "$wd"
	./moonlight.sh
}

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
echo -e " * 7: Change Default Audio Output"
echo -e " * 0: Exit"

read NUM
case "$NUM" in
	1)
		echo -e "\nPHASE ONE: Add Moonlight to Sources List"
		echo -e "****************************************\n"
		add_sources stretch
		echo -e "\n**** PHASE ONE Complete!!!! ****"

		echo -e "\nPHASE TWO: Fetch and install the GPG key"
		echo -e "****************************************\n"
		install_gpg_keys -f
		echo -e "\n**** PHASE TWO Complete!!!! ****"

		echo -e "\nPHASE THREE: Update System and install moonlight"
		echo -e "**************************\n"
		update_and_install_moonlight -u
		echo -e "\n**** PHASE THREE Complete!!!! ****"

		echo -e "\nPHASE FOUR: Pair Moonlight with PC"
		echo -e "**********************************\n"
		pair_moonlight
		echo -e "\n**** PHASE FOUR Complete!!!! ****"

		echo -e "\nPHASE FIVE: Create STEAM Menu for RetroPie"
		echo -e "*****************************************\n"
		create_menu
		echo -e "\n**** PHASE FIVE Complete!!!! ****"

		echo -e "\nPHASE SIX: Create 1080p+720p Launch Scripts for RetroPie"
		echo -e "**********************************************************\n"
		create_launch_scripts -f
		echo -e "\n**** PHASE SIX Complete!!!! ****"

		echo -e "\nPHASE SEVEN: Making Everything PI Again :)"
		echo -e "******************************************\n"
		set_permissions
		echo -e "\n**** PHASE SEVEN Complete!!!! ****\n"

		echo -e "Everything should now be installed and setup correctly."
		echo -e "To be safe, it's recommended that you perform a reboot now."
		echo -e "\nIf you don't want to reboot now, press N\n"

		read -p "Reboot Now (y/n)?" choice
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
		echo -e "*****************************\n"
		echo -e "\nWIP"
		echo -e "*****************************\n"
	;;
    
    0)  exit 1;;
	*) echo "INVALID NUMBER!" ;;
esac
