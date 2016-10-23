#!/bin/bash

#If errors in updating libraries try:
#sudo rm /var/lib/dpkg/status
#sudo touch /var/lib/dpkg/status

asd() {
cat <<"EOT"



 		         _.---""""""""""--.._
 		      .="                    "=,
 		   .-'                          ``-.
 		  :                                 :
                 :  RRVIttIti+==iiii++iii++=;:,       :
                 : IBMMMMWWWWMMMMMBXXVVYYIi=;:,        :
                 : tBBMMMWWWMMMMMMBXXXVYIti;;;:,,      :
                 t YXIXBMMWMMBMBBRXVIi+==;::;::::       ,
                ;t IVYt+=+iIIVMBYi=:,,,=i+=;:::::,      ;;
                YX=YVIt+=,,:=VWBt;::::=,,:::;;;:;:     ;;;
                VMiXRttItIVRBBWRi:.tXXVVYItiIi==;:   ;;;;
                =XIBWMMMBBBMRMBXi;,tXXRRXXXVYYt+;;: ;;;;;
                 =iBWWMMBBMBBWBY;;;,YXRRRRXXVIi;;;:;,;;;=
                  iXMMMMMWWBMWMY+;=+IXRRXXVYIi;:;;:,,;;=
                  iBRBBMMMMYYXV+:,:;+XRXXVIt+;;:;++::;;;
                  =MRRRBMMBBYtt;::::;+VXVIi=;;;:;=+;;;;=
                   XBRBBBBBMMBRRVItttYYYYt=;;;;;;==:;=
                    VRRRRRBRRRRXRVYYIttiti=::;:::=;=
                     YRRRRXXVIIYIiitt+++ii=:;:::;==
                     +XRRXIIIIYVVI;i+=;=tt=;::::;:;
                      tRRXXVYti++==;;;=iYt;:::::,;;
                       IXRRXVVVVYYItiitIIi=:::;,::;
                        tVXRRRBBRXVYYYIti;::::,::::
                         YVYVYYYYYItti+=:,,,,,:::::;
                         YRVI+==;;;;;:,,,,,,,:::::::

      L I V E    L O N G    A N D     P R O S P E R


        +-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+
           |i|n|s|t|a|l|l|e|r|
        +-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+


EOT
}

asd



HEADLESS=Y
STRIPALL=Y
OPTIMIZE=Y
FIRMWARE=Y
WIFIHOTSPOT=N
WIFINTW=Y
WEBSERVER=Y
MJPG=Y

read -p "Running Headless? [$HEADLESS]: " -e t1
if [ -n "$t1" ]; then HEADLESS="$t1";fi

read -p "Remove extra Packages? [$STRIPALL]: " -e t1
if [ -n "$t1" ]; then STRIPALL="$t1";fi

read -p "Optimize system? [$OPTIMIZE]: " -e t1
if [ -n "$t1" ]; then OPTIMIZE="$t1";fi

read -p "Update Firmware? [$FIRMWARE]: " -e t1
if [ -n "$t1" ]; then FIRMWARE="$t1";fi

read -p "Configure Wi-Fi adapter? [$WIFINTW]: " -e t1
if [ -n "$t1" ]; then WIFINTW="$t1";fi

read -p "Configure Wi-fi hotspot? [$WIFIHOTSPOT]: " -e t1
if [ -n "$t1" ]; then WIFIHOTSPOT="$t1";fi

read -p "Install webserver (node.js, socket.io, etc)? [$WEBSERVER]: " -e t1
if [ -n "$t1" ]; then WEBSERVER="$t1";fi

read -p "Install MJPEG server? [$MJPG]: " -e t1
if [ -n "$t1" ]; then MJPG="$t1";fi



sudo bash /usr/local/bin/fs-resize.sh
#sudo bash /usr/local/bin/odroid-utlity.sh


df -h
START=$SECONDS
echo -n START

if [ "$WIFINTW" == "Y" ]
then
 sudo bash setupWiFi.sh
fi


if [ "$HEADLESS" == "Y" ]
then

sudo bash headless.sh


fi


sudo locale-gen en_GB.utf8
sudo locale-gen de_CH.UTF-8
sudo update-locale
sudo dpkg-reconfigure locales

#list all installed packages: dpkg --get-selections
if [ "$STRIPALL" == "Y" ]
then
{
echo "*** Stripping down ***"


} #>> log.txt

else
    echo "No extra packages removed"
fi

################# Optimization scripts #################

if [ "$OPTIMIZE" == "Y" ]
then

} >> log.txt



else
    echo "System tweaks not applied"
fi


echo -e "***** Updating system packages *****"
{
sudo apt-get -f install
sudo apt-get update
sudo apt-get autoremove -y  --purge
sudo apt-get clean
sudo apt-get -y upgrade
#sudo apt-get -y dist-upgrade

} #>> log.txt


################# Update firmware #################
if [ "$FIRMWARE" == "Y" ]
then
echo -e "***** Updating firmware *****"
sudo bash /usr/local/bin/kernel_update.sh
else
    echo "Firmware NOT updated"
fi


################# Installing Web server items #################
if [ "$MJPG" == "Y" ]
then

echo -e "***** Installing mjpg-streamer *****"
#https://miguelmota.com/blog/raspberry-pi-camera-board-video-streaming/
{
    # Install dev version of libjpeg
    sudo apt-get install -y libjpeg62-dev

    # Install cmake
    sudo apt-get install -y cmake

    # Download mjpg-streamer with raspicam plugin
    git clone https://github.com/jacksonliam/mjpg-streamer.git ~/mjpg-streamer

    # Change directory
    cd ~/mjpg-streamer/mjpg-streamer-experimental

    # Compile
    make clean all

    # Replace old mjpg-streamer
    sudo rm -rf /opt/mjpg-streamer
    sudo mv ~/mjpg-streamer/mjpg-streamer-experimental /opt/mjpg-streamer
    sudo rm -rf ~/mjpg-streamer
} >> log.txt


# Begin streaming
#LD_LIBRARY_PATH=/opt/mjpg-streamer/ /opt/mjpg-streamer/mjpg_streamer -i "input_raspicam.so -fps 15 -q 50 -x 640 -y 480" -o "output_http.so -p 9000 -w /opt/mjpg-streamer/www" &

fi

if [ "$WEBSERVER" == "Y" ]
then

echo -e "***** Installing node *****"
sudo apt-get instal node


exit

echo -e ""***** Testing Node installation "*****"
node -v

echo -e "***** Installing socket.io *****"
sudo npm install -g socket.io
#/usr/local/lib/node_modules/socket.io

echo -e "***** Installing express and other packages *****"
{
    sudo npm install -g express
    sudo npm install -g express-generator
    sudo npm install -g safefs
    sudo npm install -g serialport
    sudo npm install -g nconf
}
#>> log.txt
fi


if [ "$WIFIHOTSPOT" == "Y" ]
then
    #git clone https://github.com/cymplecy/pispot.git
   #sudo bash pispot/install_hotspot8188CUS.sh
   sudo bash installHS.sh
else
    echo "No Wi-Fi hot spot configured"
fi


END=$SECONDS
echo -n "It took $(($END - $START)) Seconds "
df -h

exit 0
