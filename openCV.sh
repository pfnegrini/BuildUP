#!/bin/bash

echo -e "***** Setting up  OpenCV *****"
sudo apt-get install -y build-essential cmake pkg-config
sudo apt-get install -y libjpeg8-dev libtiff4-dev libjasper-dev libpng12-dev
sudo apt-get install -y libgtk2.0-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install -y libatlas-base-dev gfortran
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo pip install virtualenv virtualenvwrapper
sudo rm -rf ~/.cache/pip

# virtualenv and virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
source ~/.profile
mkvirtualenv cv

sudo apt-get install -y python2.7-dev

wget https://github.com/opencv/opencv/archive/2.4.13.zip -O opencv.zip
#git clone https://github.com/opencv/opencv.git
#wget -O opencv-2.4.10.zip http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/2.4.10/opencv-2.4.10.zip/download
unzip opencv.zip
cd opencv

/*
inflating: opencv-2.4.13/samples/winrt/OcvImageProcessing/OcvImageProcessing/pch.h  
openCV.sh: line 26: cd: opencv: No such file or directory
***** Configuring make *****
CMake Error: The source directory "/home/odroid/BuildUP" does not appear to contain CMakeLists.txt.
Specify --help for usage, or press the help button on the CMake GUI.
***** Compiling *****
make: *** No targets specified and no makefile found.  Stop.
make: *** No rule to make target 'install'.  Stop.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
*/

echo -e "***** Configuring make *****"
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_NEW_PYTHON_SUPPORT=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON  -D BUILD_EXAMPLES=ON ..


echo -e "***** Compiling *****"
make

sudo make install
sudo ldconfig

cd ~/.virtualenvs/cv/lib/python2.7/site-packages/
ln -s /usr/local/lib/python2.7/site-packages/cv2.so cv2.so
ln -s /usr/local/lib/python2.7/site-packages/cv.py cv.py

#Needed for python
sudo apt-get install python-opencv


