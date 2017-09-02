#!/bin/bash

echo -e "\n******************************************************"
echo -e "Welcome to the Moonlight Installer Script for RetroPie"
echo -e "******************************************************\n"
echo -e "\nPlease make sure you have done the following:\n"
echo -e "\n1: Checked that you have an Nvidia Graphics Card GTX650+"
echo -e "2: Updated your Nvidia Drivers on your PC"
echo -e "3: Enabled GAMESTREAM in GeForce Experience on PC"
echo -e "4: You are running RetroPie 4.2+ on your Raspberry Pi"
echo -e "5: You are connected to the same network as PC (preferably Wired)"
echo -e "6: Your controller is hooked up to your Raspberry Pi"
echo -e "7: You have subscribed to youtube.com/TechWizTime :)"
echo -e "\nIf you need to exit, do it now by pressing CTRL+C otherwise\n\n\n"
read -n 1 -s -p "Press anykey to continue"


echo -e "\n*******************************************"
echo -e "PHASE ONE: Adding Moonlight to Sources List"
echo -e "*******************************************\n"
echo "deb http://archive.itimmer.nl/raspbian/moonlight jessie main" >> /etc/apt/sources.list
echo -e "\nDONE!!\n"


echo -e "\n****************************************"
echo -e "PHASE TWO: Fetch and install the GPG key"
echo -e "****************************************\n"
wget http://archive.itimmer.nl/itimmer.gpg
apt-key add itimmer.gpg



echo -e "\n*******************************"
echo -e "PHASE THREE: Run a quick UPDATE"
echo -e "*******************************\n"
apt-get update -y


echo -e "\n**************************************"
echo -e "PHASE FOUR: Install Moonlight Software"
echo -e "**************************************\n"
apt-get install moonlight-embedded
echo -e "\nDONE!!\n"

echo -e "\n***************************************"
echo -e "PHASE FIVE: Pairing Moonlight with STEAM"
echo -e "***************************************\n"
echo -e "Once you have input your STEAM PC's IP Address below, you will be given a PIN"
echo -e "Input this on the STEAM PC to pair with Moonlight. \n"
read -p "Input STEAM PC's IP Address here :`echo $'\n> '`" ip
sudo -u pi moonlight pair $ip


echo -e "\n**************************************************"
echo -e "PHASE SIX: Create Launching Scripts for RetroPie"
echo -e "**************************************************\n"
mkdir /home/pi/RetroPie/roms/moonlight
cd /home/pi/RetroPie/roms/moonlight
echo "#!/bin/bash" > moonlight720p30fps.sh
echo "moonlight stream -720 -fps 30 "$ip"" >>  moonlight720p30fps.sh
echo "#!/bin/bash" > moonlight720p60fps.sh
echo "moonlight stream -720 -fps 60 "$ip"" >>  moonlight720p60fps.sh
echo "#!/bin/bash" > moonlight1080p30fps.sh
echo "moonlight stream -1080 -fps 30 "$ip"" >>  moonlight1080p30fps.sh
echo "#!/bin/bash" > moonlight1080p60fps.sh
echo "moonlight stream -1080 -fps 60 "$ip"" >>  moonlight1080p60fps.sh
chmod +x moonlight720p30fps.sh
chmod +x moonlight720p60fps.sh
chmod +x moonlight1080p30fps.sh
chmod +x moonlight1080p60fps.sh


echo -e "\n*******************************************"
echo -e "PHASE SEVEN: Create STEAM Menu for RetroPie"
echo -e "*******************************************\n"
if [ -f /home/pi/.emulationstation/es_systems.cfg ]
then
	echo -e "\nAdding Steam to Systems \n"
	sed -i -e 's|</systemList>|  <system>\n    <name>steam</name>\n    <fullname>Steam</fullname>\n    <path>~/RetroPie/roms/moonlight</path>\n    <extension>.sh .SH</extension>\n    <command>bash %ROM%</command>\n    <platform>steam</platform>\n    <theme>steam</theme>\n  </system>\n</systemList>|g' /home/pi/.emulationstation/es_systems.cfg
else
	echo -e "\nCopying Systems Config File \n"
	cp /etc/emulationstation/es_systems.cfg /home/pi/.emulationstation/es_systems.cfg
	echo -e "\nAdding Steam to Systems \n"
	sed -i -e 's|</systemList>|  <system>\n    <name>steam</name>\n    <fullname>Steam</fullname>\n    <path>~/RetroPie/roms/moonlight</path>\n    <extension>.sh .SH</extension>\n    <command>bash %ROM%</command>\n    <platform>steam</platform>\n    <theme>steam</theme>\n  </system>\n</systemList>|g' /home/pi/.emulationstation/es_systems.cfg
fi


echo -e "\n*****************************************"
echo -e "PHASE NINE: Making Everything PI Again :)"
echo -e "*****************************************\n"
chown -R pi:pi /home/pi/RetroPie/roms/moonlight/
chown -R pi:pi /opt/retropie/configs/moonlight/
chown pi:pi /home/pi/.emulationstation/es_systems.cfg


echo -e "\n\n\n************************************************"
echo -e "INSTALL and SETUP Script for Moonlight completed"
echo -e "************************************************\n\n\n"

echo -e "\nIf you don't want to reboot now, press N\n"

read -p "Reboot Now (y/n)?" choice
case "$choice" in 
  y|Y ) shutdown -r now;;
  n|N ) exit 1;;
  * ) echo "invalid";;
esac
