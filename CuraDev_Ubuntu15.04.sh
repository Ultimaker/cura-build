#!/bin/bash
# This is a script which get the latest git repo and build them.
# Tested under ubuntu 15.04, PyQT 5.4.1 which is required by cura.
# Origin from derekhe, Modified by openthings@163.com.

# Update include:
# 1.Update source automaticly.
# 2.Get gtest source from github.
# 3.Merge plugins from Uranium into Cura.

cd ~
if [ ! -d "dev" ]; then
    mkdir dev
fi
cd dev

sudo apt-get install -y git cmake cmake-gui autoconf libtool python3-setuptools curl python3-pyqt5.* python3-numpy qml-module-qtquick-controls

#protobuf.
#https://github.com/google/protobuf.git

echo "================================="
echo "Install Protobuf."
if [ ! -d "protobuf" ]; then
    git clone https://github.com/Ultimaker/protobuf.git
    cd protobuf
else
    cd protobuf
    git pull        
fi
echo "================================="
echo "get gtest."
if [ ! -d "gtest" ]; then
    git clone https://github.com/kgcd/gtest.git
else
    git pull
fi
echo "================================="
echo "get gmock."
if [ ! -d "gmock" ]; then
    git clone https://github.com/krzysztof-jusiak/gmock.git
else
    git pull        
fi
echo "Build Protobuf."
./autogen.sh
./configure --prefix=/usr
make -j4
sudo make install
sudo ldconfig
cd python
python3 setup.py build
sudo python3 setup.py install
cd ../..

echo "================================="
echo "Install libArcus."
if [ ! -d "libArcus" ]; then
    git clone https://github.com/Ultimaker/libArcus
    cd libArcus
else
    cd libArcus
    git pull        
fi
if [ ! -d "build" ]; then
  mkdir build
fi
cd build
#cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DPYTHON_SITE_PACKAGES_DIR=/usr/lib/python3.4/dist-packages
cmake .. -DPYTHON_SITE_PACKAGES_DIR=/usr/lib/python3.4/dist-packages
make -j4
sudo make install
cd ../../

echo "================================="
echo "Install CuraEngine."
if [ ! -d "CuraEngine" ]; then
    git clone https://github.com/Ultimaker/CuraEngine.git
    cd CuraEngine
else
    cd CuraEngine
    git pull        
fi
if [ ! -d "build" ]; then
  mkdir build
fi
cd build
#cmake .. -DCMAKE_INSTALL_PREFIX=/usr
cmake .. 
make -j4
sudo make install
cd ../../

echo "================================="
echo "Install Uranium."
if [ ! -d "Uranium" ]; then
    git clone https://github.com/Ultimaker/Uranium.git
    cd Uranium
else
    cd Uranium
    git pull        
fi
if [ ! -d "build" ]; then
  mkdir build
fi
cd build
#cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DPYTHON_SITE_PACKAGES_DIR=/usr/lib/python3.4/dist-packages -DURANIUM_PLUGINS_DIR=/usr/lib/python3.4/dist-packages
cmake .. -DPYTHON_SITE_PACKAGES_DIR=/usr/lib/python3.4/dist-packages -DURANIUM_PLUGINS_DIR=/usr/lib/python3.4/dist-packages
sudo make install
cd ../..

echo "================================="
echo "Install Cura."
if [ ! -d "Cura" ]; then
    git clone https://github.com/Ultimaker/Cura.git
    cd Cura
else
    cd Cura
    git pull        
fi
cd ..
echo "Build finished."

echo "============================================================================"
echo "Merge Resource into Cura/resources/"
cp -rv Uranium/resources/* Cura/resources/
echo "Merge Plugins into Cura/plugins/"
cp -rv Uranium/plugins/* Cura/plugins/
echo "Link:"$PWD"/CuraEngine/build/CuraEngine"
sudo ln -s $PWD/CuraEngine/build/CuraEngine /usr/bin/CuraEngine

echo "Starting Cura......"
cd Cura
python3 cura_app.py
echo "You need add to /etc/profile:export PYTHONPATH=/usr/lib/python3/dist-packages"
echo "============================================================================="
