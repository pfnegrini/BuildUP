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
           |R|P|i| |i|n|s|t|a|l|l|e|r|
        +-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+


EOT
}

asd

echo -n "Want to configure Wi-Fi hotspot? [Y/N]"
read WIFICLIENT

echo -n "Running headless? [Y/N]"
read HEADLESS

echo -n "Remove extra packages? [Y/N]"
read STRIPALL

echo -n "Optimize? [Y/N]"
read OPTIMIZE


echo -n "Update firmware? [Y/N]"
read FIRMWARE

echo -n "Install robotserver? [Y/N]"
read ROBOTSERVER

df -h
START=$SECONDS
echo -n START

sudo locale-gen en_GB.utf8

cd BuildUP

#list all installed packages: dpkg --get-selections
if [ "$STRIPALL" == "Y" ]
then
{
echo "*** Stripping down ***"

apt-get autoremove -y scratch
apt-get autoremove -y dillo
apt-get autoremove -y xpdf
apt-get autoremove -y galculator
apt-get autoremove -y idle-python3.2
apt-get autoremove -y hicolor-icon-theme
sudo apt-get purge -y xserver* -y
sudo apt-get purge -y ^x11 -y
sudo apt-get purge -y ^libx -y
sudo apt-get purge -y ^lx -y
sudo apt-get purge -y samba* -y
sudo apt-get purge -y supercollider* -y
sudo apt-get purge -y netsurf* -y
sudo apt-get purge -y plymouth* -y
sudo apt-get remove -y task-desktop
sudo apt-get autoremove -y midori
sudo apt-get autoremove -y lxde-icon-theme
sudo apt-get autoremove -y omxplayer

sudo rm -rv /usr/share/icons/*
sudo rm -rv /opt/vc/src/*
sudo rm -rv /usr/share/images/*
sudo rm -rv python_games
sudo rm -rv /opt/*
sudo rm -rv /usr/games/
sudo rm -rv /usr/share/squeak/
sudo rm -rv /usr/share/sounds/
sudo rm -rv /usr/share/wallpapers
sudo rm -rv /usr/share/themes
sudo rm -rv /usr/share/kde4

sudo apt-get remove -y --purge wolfram-engine
sudo apt-get remove -y --purge obconf openbox raspberrypi-artwork xarchiver xinit

} #>> log.txt

else
    echo "No extra packages removed"
fi

if [ "$OPTIMIZE" == "Y" ]
then
echo -e "***** Optimizing system *****"
echo -e "***** Replace syslog *****"
{
#Replace rsyslogd with inetutils-syslogd and remove useless logs
#Reduce memory and cpu usage. We just need a simple vanilla syslogd. Also there is no need to log so many files. Just dump them into /var/log/(cron/mail/messages)
sudo apt-get -y remove -y --purge rsyslog
sudo apt-get -y install inetutils-syslogd
sudo service inetutils-syslogd stop

for file in /var/log/*.log /var/log/mail.* /var/log/debug /var/log/syslog; do [ -f "$file" ] && rm -f "$file"; done
for dir in fsck news; do [ -d "/var/log/$dir" ] && rm -rf "/var/log/$dir"; done
sudo mkdir -p /etc/logrotate.d
echo -e "/var/log/cron\n/var/log/mail\n/var/log/messages {\n\trotate 4\n\tweekly\n\tmissingok\n\tnotifempty\n\tcompress\n\tsharedscripts\n\tpostrotate\n\t/etc/init.d/inetutils-syslogd reload >/dev/null\n\tendscript\n}" > /etc/logrotate.d/inetutils-syslogd
sudo service inetutils-syslogd start
} >> log.txt


#https://extremeshok.com/1081/raspberry-pi-raspbian-tuning-optimising-optimizing-for-reduced-memory-usage/

sudo sed -i '/[2-6]:23:respawn:\/sbin\/getty 38400 tty[2-6]/s%^%#%g' /etc/inittab
#Optimize / mount
sudo sed -i 's/defaults,noatime/defaults,noatime,nodiratime/g' /etc/fstab

#Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disableipv6.conf
echo 'blacklist ipv6' >> /etc/modprobe.d/blacklist
sed -i '/::/s%^%#%g' /etc/hosts

#Replace Deadline Scheduler with NOOP Scheduler
sed -i 's/deadline/noop/g' /boot/cmdline.txt

#in  /boot/config.txt:
#gpu_mem=16

else
    echo "System tweaks not applied"
fi


echo -e "***** Updating system packages *****"
{
sudo apt-get -f install
sudo apt-get update
sudo apt-get autoremove -y
sudo apt-get clean
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade

} >> log.txt



if [ "$FIRMWARE" == "Y" ]
then
echo -e "***** Updating firmware *****"
    sudo rpi-update
else
    echo "Firmware NOT updated"
fi

echo -e "***** Enabling Turbo *****"
#700Mhz-1000Mhz dynamic: Scales the cpu frequency according to the load
echo -e "force_turbo=0" >> /boot/config.txt

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

echo -e "***** Installing node *****"
wget http://node-arm.herokuapp.com/node_latest_armhf.deb
sudo dpkg -i node_latest_armhf.deb

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
}
#>> log.txt

if [ "$ROBOTSERVER" == "Y" ]
then
    echo -e "***** Setting up robotserver *****"
    mkdir /home/pi/Documents
    mkdir /home/pi/Documents/Sketches
    mkdir /home/pi/Documents/Sketches/Bailey
    cd /home/pi/Documents/Sketches/Bailey
    git clone https://github.com/pfnegrini/Bailey.git /home/pi/Documents/Sketches/Bailey
    sudo cp /home/pi/Documents/Sketches/Bailey/server/install/robotserver /etc/init.d/robotserver
    sudo chmod 0755 /etc/init.d/robotserver
    sudo update-rc.d robotserver defaults
else
    echo "Robotserver NOT configured"
fi

if [ "$WIFICLIENT" == "Y" ]
then
    #git clone https://github.com/cymplecy/pispot.git
   #sudo bash pispot/install_hotspot8188CUS.sh
   sudo bash installHS.sh
else
    echo "No Wi-Fi client configured"
fi

END=$SECONDS
echo -n "It took you $(($END - $START)) Seconds "
df -h

exit 0
