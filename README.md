BuildUP
=======

Script used to optimize Ubuntu on singel board computer such as Odroid or Raspberry Pi to run minimal and headless. This is useful as I often experiment with Raspberry and need to ensure setup is consistent. The script also installs Node, Socket.io, mjpeg streamer and other app to build remote controlled robots.

I believe that stripping down Ubuntu for single board computers is better than build up a light distribution as this will allow to benefit from constant updates and community help while still maintaining a light footprint.

Where possilve I compile from source (e.g.: node js and openCV), this ensure portability of ht scripts trgought hardwre platforms. 

Be carefull as it will remove a LOT and, depending on how you use your board, potentially it mightcause unstability.

Areas of research:
1. Add a menu to install other applications such as TL server or Bailey 
2. Make it more friendly
3. Look for new optimizations/packages to be removed

NOTE: this software includes tips found all over the Internet that are public domain. Please contact me in case you think part of it should be attributed.
