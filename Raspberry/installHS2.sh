#!/bin/bash
#
# Raspberry Pi install RTL8188CUS nan wifi USB adaptor
#by Paul Miller
#Revisions:
# 0.1 - 25/04/2013 Initial Release
# 0.1 SW 01Aug2014 - change to use as Hotspot and not AP
#
#
###################################################


###################################################
#set default values
###################################################
# General
CURRENT_AUTHOR="idkpmiller@sip2serve.com"

# Network Interface
IP4_CONF_TYPE=STATIC
IP4_ADDRESS=10.0.0.1
IP4_NETMASK=255.255.255.0
IP4_NETWORK=${IP4_ADDRESS%?}0
IP4_BROADCAST=${IP4_ADDRESS%?}255
IP4_GATEWAY=${IP4_ADDRESS}
IP4_DNS1=8.8.8.8.8
IP4_DNS2=4.4.4.4
IP4_STARTADDRESS=${IP4_ADDRESS%?}2
IP4_ENDADDRESS=${IP4_ADDRESS%?}50


# Wifi Access Point
AP_COUNTRY=CH
AP_CHAN=11
AP_SSID=ClassPi
AP_PASSPHRASE=PASSWORD # not used in practice

# Wifi network
WF_SSID=ClassPi
WF_PASSPHRASE=PASSWORD # not used in practice



###################################################
echo " performing a series of prechecks..."
###################################################

#check current user privileges
  (( `id -u` )) && echo "This script MUST be ran with root privileges, try prefixing with sudo. i.e sudo $0" && exit 1

#check  that USB wifi device is plugged in and seen
if [[ -n $(lsusb | grep RTL8188CUS) ]]; then
    echo "The RTL8188CUS device has been successfully located."
else
    echo "The RTL8188CUS device has not been located, check it is inserted and run script again when done."
    exit 1
fi

#check that internet connection is available

# the hosts below are selected for their high availability,
# if it is more apprioriate to change a host to equal one that is
# required for the script then simply change the FQDN chosen below 
# to check the availabilty for the host before the script gets underway

host1=google.com
host2=wikipedia.org
((ping -w5 -c3 $host1 || ping -w5 -c3 $host2) > /dev/null 2>&1) && echo "Internet connectivity - OK" || (echo "Internet connectivity - Down, Internet connectivity is required for this script to complete. exiting..." && exit 1)

#pre-checks complete#####################################################

#clear the screen
clear

# Get Input from User
echo "Capture User Settings:"
echo "====================="
echo "Please answer the following questions."
echo "Hitting return will continue with the default option"
echo
echo

#read -p "IPv4 DHCP or STATIC? [$IP4_CONF_TYPE]: " -e t1
#if [ -n "$t1" ]; then IP4_CONF_TYPE="$t1";fi

if [ "$IP4_CONF_TYPE" = "STATIC" ]; then

read -p "IPv4 Address [$IP4_ADDRESS]: " -e t1
if [ -n "$t1" ]; then IP4_ADDRESS="$t1";fi

read -p "IPv4 Netmask [$IP4_NETMASK]: " -e t1
if [ -n "$t1" ]; then IP4_NETMASK="$t1";fi

read -p "IPv4 Network [$IP4_NETWORK]: " -e t1
if [ -n "$t1" ]; then IP4_NETWORK="$t1";fi

read -p "IPv4 Broadcast [$IP4_BROADCAST]: " -e t1
if [ -n "$t1" ]; then IP4_BROADCAST="$t1";fi

read -p "IPv4 Gateway Address [$IP4_GATEWAY]: " -e t1
if [ -n "$t1" ]; then IP4_GATEWAY="$t1";fi

read -p "IPv4 Primary DNS server [$IP4_DNS1]: " -e t1
if [ -n "$t1" ]; then IP4_DNS1="$t1";fi

read -p "IPv4 Secondary DNS server [$IP4_DNS2]: " -e t1
if [ -n "$t1" ]; then IP4_DNS2="$t1";fi
fi

# wifi settings
read -p "Wifi Country [$AP_COUNTRY]: " -e t1
if [ -n "$t1" ]; then AP_COUNTRY="$t1";fi

read -p "Wifi Channel Name [$AP_CHAN]: " -e t1
if [ -n "$t1" ]; then AP_CHAN="$t1";fi

read -p "Wifi SSID [$AP_SSID]: " -e t1
if [ -n "$t1" ]; then AP_SSID="$t1";fi

read -p "Wifi PassPhrase (min 8 max 63 characters) [$AP_PASSPHRASE]: " -e t1
if [ -n "$t1" ]; then AP_PASSPHRASE="$t1";fi

read -p "Wifi PassPhrase (min 8 max 63 characters) [$WF_SSID]: " -e t1
if [ -n "$t1" ]; then WF_SSID="$t1";fi

read -p "Wifi PassPhrase (min 8 max 63 characters) [$WF_PASSPHRASE]: " -e t1
if [ -n "$t1" ]; then WF_PASSPHRASE="$t1";fi

###################################################
# Get Decision from User
###################################################

  echo "Hotspot Setup"
  echo "======================"
  echo "Please answer the following question."
  echo "Hitting return will continue with the default 'No' option"
  echo

# Point of no return
  read -p "Do you wish to continue and Setup RPi as an Hotspot? (y/n) " RESP
  if [ "$RESP" = "y" ]; then

  clear
  echo "Configuring RPI as an Hotspot Point...."
  # update system
  echo ""
  echo "#####################PLEASE WAIT##################"######
  echo -en "Package list update                                 "
  apt-get -qq update 
  echo -en "[OK]\n"

  echo -en "Adding packages ... please wait ....                      "
  apt-get -y -qq install hostapd bridge-utils iw dnsmasq > /dev/null 2>&1
  apt-get -y -qq remove ifplugd > /dev/null 2>&1
  echo -en "[OK]\n"

#check  that iw list fails with 'nl80211 not found'
  echo -en "iw list check                                       "
  iw list > /dev/null 2>&1 | grep 'nl80211 not found'
  rc=$?
  if [[ $rc = 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    echo "A check that should have a known outcome has has not"
    echo "produced the expected result, it is best to manually"
    echo "proceed and ask for assistance from the RPi forum or"
    echo "the authour of this version of the script."
    echo $CURRENT_AUTHOR
    exit $rc
  else
    echo -en "[OK]\n"
  fi

#creat the default file to point at the configuration file
  echo -en "Create Default hostapd file                         "
  cat <<EOF > /etc/default/hostapd
#created by $0
DAEMON_CONF="/etc/hostapd/hostapd.conf"
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

#create the hostapd configuration to match what the user has provided
  echo -en "Create hostapd.conf file                            "
  cat <<EOF > /etc/hostapd/hostapd.conf
#created by $0
interface=wlan0
driver=rtl871xdrv
country_code=$AP_COUNTRY
ctrl_interface=wlan0
ctrl_interface_group=0
ssid=$AP_SSID
hw_mode=g
channel=$AP_CHAN
wpa=3
wpa_passphrase=$AP_PASSPHRASE
wpa_key_mgmt=WPA-PSK
#wpa_pairwise=TKIP
#rsn_pairwise=CCMP
beacon_int=100
auth_algs=3
macaddr_acl=0
wmm_enabled=1
eap_reauth_period=360000000
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

# backup the existing interfaces file
  echo -en "Backup network interface configuration              "
cp /etc/network/interfaces /etc/network/interfaces.bak
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
#  echo -en "[OK]\n"

# create the following network interface file based on user input
  echo -en "Create new network interface configuration          "
if [ "$IP4_CONF_TYPE" = "DHCP" ]; then
cat <<EOF > /etc/network/interfaces
#created by $0
#
# RPI-WIFI-CONF Autogenerated File
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
fi


if [ "$IP4_CONF_TYPE" = "STATIC" ]; then
cat <<EOF > /etc/network/interfaces
#created by $0
auto lo
iface lo inet loopback
allow-hotplug eth0
iface eth0 inet dhcp

auto wlan0
allow-hotplug wlan0
iface wlan0 inet static
   address $IP4_ADDRESS
   network $IP4_NETWORK
   netmask $IP4_NETMASK
   broadcast $IP4_BROADCAST
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

#create the dnsmasq.conf configuration to match what the user has provided
  echo -en "Create dnsmasq.conf file                            "
  cat <<EOF > /etc/dnsmasq.conf
#created by $0
interface=wlan0 # To get dnsmasq to listen only on wlan0.
dhcp-range=$IP4_STARTADDRESS,$IP4_ENDADDRESS,$IP$_NETMASK,12h 
EOF
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi

#deal with the hostapd binary file
  echo -en "change directory                                    "
cd /usr/sbin
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
#  echo -en "[OK]\n"

# backup the old hostapd file
  echo -en "Backup hostapd file                                 "
cp /usr/sbin/hostapd /usr/sbin/hostapd.bak
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
#  echo -en "[OK]\n"

# delete the old hostapd file
  echo -en "Delete old hostapd file                             "
rm -f hostapd
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
#  echo -en "[OK]\n"

# Download the replacement file
  echo -en "Download the hostapd file                           "
  wget https://www.dropbox.com/s/pl9tn35ay2b92dc/hostapd
#> /dev/null 2>&1
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
#  echo -en "[OK]\n"

# make sure root has ownership of the file
  echo -en "Modify hostapd ownership                            "
chown root:root hostapd
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
#  echo -en "[OK]\n"

# make the new file executable
  echo -en "Modify the hostapd file permissions                 "
chmod 755 hostapd
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi
  echo -en "[OK]\n"

  echo "###################INSTALL COMPLETE###############"######
  echo "The Pi will now be rebooted to activate the changes"
  read -p "Press [Enter] key to reboot...                    "
  reboot
 Restart the networking configuration to activate the changes
/etc/init.d/networking restart

 Restart the access point software
/etc/init.d/hostapd restart

####################################################################
else
echo "exiting..."
fi
exit 0



