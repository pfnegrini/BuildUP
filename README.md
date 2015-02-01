BuildUP
=======

Script used to optimize Rasbian to run minimal and headless. This is useful as I often experiment with Raspberry and need to ensure setup is consistent. The script also installs Node, Socket.io, mjpeg streamer and other app to build remote controlled robots.

I believe that stripping down Raspian is better than build up a light distribution as this will allow to benefit from constant updates and community help while still maintaining a light footprint.

Be carefull as it will remove a LOT and, depending on how you use your Raspberry-Pi, potentially it mightcause unstability.

Areas of research:
1. Add a menu to install other applications such as TL server or Bailey 
2. Make it more friendly
3. Look for new optimizations/packages to be removed

Instructions:
1. Install Rasbian (sudo dd bs=4M if=/home/paolo/Temp/2014-09-09-wheezy-raspbian.img  | pv -s 3G | sudo dd of=/dev/sdc)
2. Connect the PI to the Internet
2. ssh the Pi to find IP: sudo nmap -sP 192.168.1.0/24 | awk '/^Nmap/{ip=$NF}/B8:27:EB/{print ip}'
3. Aswer the questions and have fun seeing the script working for you

NOTE: this software includes tips found all over the Internet that are public domain. Please contact me in case you think part of it should be attributed.  
