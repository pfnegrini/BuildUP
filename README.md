BuildUP
=======

Collection of script used to optimize Rasbian to run minimal and headless. This is useful as I oftern expriment with Raspberry and need to ensure the setu is consistent. THe script also installs Node, Socket.io, mjpeg streamer and other app to build remote controlled robots.

I believe that stripping down Raspian is better than build up a light distribution as this will allow to benefit from constant updates and community help while still maintaining a light footprint.

Be carefull as it will remove a LOT and potentially make the sytem unstable.

Areas of research:
1. Add a menu to install other applications such as TL server or Bailey 
2. Make it more friendly
3. Look for new optimizations/packages to be removed

Instructions:
1. Install Rasbian (sudo dd bs=4M if=/home/paolo/Temp/2014-09-09-wheezy-raspbian.img  | pv -s 3G | sudo dd of=/dev/sdc)
2. Connect the PI to the Internet
2. ssh the Pi to find IP: sudo nmap -sP 192.168.1.0/24 | awk '/^Nmap/{ip=$NF}/B8:27:EB/{print ip}'
3. Aswer the questions and have fun seeing the script working for you

NOTE: this software includes tips found all over the Internet that are public domain. Please contat me in case you think part of it should be attributed.  
