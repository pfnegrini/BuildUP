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



HEADLESS=Y
STRIPALL=Y
OPTIMIZE=Y
FIRMWARE=Y
WIFIHOTSPOT=N
WIFINTW=Y
WEBSERVER=Y

read -p "RUnning Headless? [$HEADLESS]: " -e t1
if [ -n "$t1" ]; then HEADLESS="$t1";fi

read -p "Remove extra PAckages? [$STRIPALL]: " -e t1
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
sudo apt-get -y purge libx11-6 libgtk-3-common xkb-data lxde-icon-theme raspberrypi-artwork penguinspuzzle

} #>> log.txt

else
    echo "No extra packages removed"
fi

################# Optimization scripts #################

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

echo -e "***** Enabling Turbo *****"
#700Mhz-1000Mhz dynamic: Scales the cpu frequency according to the load
echo -e "force_turbo=0" >> /boot/config.txt


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

} #>> log.txt


################# Update firmware #################
if [ "$FIRMWARE" == "Y" ]
then
echo -e "***** Updating firmware *****"
    sudo rpi-update
else
    echo "Firmware NOT updated"
fi


################# Installing Web server items #################
if [ "$WEBSERVER" == "Y" ]
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
fi


if [ "$WIFIHOTSPOT" == "Y" ]
then
    #git clone https://github.com/cymplecy/pispot.git
   #sudo bash pispot/install_hotspot8188CUS.sh
   sudo bash installHS.sh
else
    echo "No Wi-Fi hot spot configured"
fi

if [ "$WIFINTW" == "Y" ]
then

WF_SSID=WirelessSSID
WF_PASSPHRASE=password

read -p "SSID [$SSID]: " -e t1
if [ -n "$t1" ]; then SSID="$t1";fi

read -p "Password [$WF_PASSPHRASE]: " -e t1
if [ -n "$t1" ]; then WF_PASSPHRASE="$t1";fi

read -p "Create script events? [$WF_SCRIPTS]: " -e t1
if [ -n "$t1" ]; then WF_SCRIPTS="$t1";fi


cat <<EOF > /etc/network/interfaces

#created by $0
#
# Network interfaces autogenerated file
#

auto lo

iface lo inet loopback
iface eth0 inet dhcp
	pre-up /usr/local/bin/upWifi.sh

auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
  wpa-ssid $WF_SSID
  wpa-psk  $WF_PASSPHRASE
  post-down /usr/local/bin/downWifi.sh
  pre-up /usr/local/bin/upWifi.sh
EOF
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
#  echo -en "[OK]\n"


if [ "$WF_SCRIPTS" == "Y" ]
then

cat <<EOF > /etc/network/if-up.d/upWifi.sh
#!/bin/bash
#created by $0
#
# Run script if network goes down
#
echo "`date -u` network DOWN" >> /home/pi/ntwlog.txt

EOF
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
#  echo -en "[OK]\n"


cat <<EOF > /etc/network/if-down.d/upWifi.sh
#!/bin/bash
#created by $0
#
# Run script if network goes up
#

echo "`date -u` network UP" >> /home/pi/ntwlog.txt


EOF
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
#  echo -en "[OK]\n"

fi

fi

sudo chmod 755 /etc/network/if-up.d/upWifi.sh
sudo chmod 755 /etc/network/if-down.d/upWifi.sh


fi

END=$SECONDS
echo -n "It took $(($END - $START)) Seconds "
df -h

exit 0
