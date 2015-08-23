#/bin/bash
# This is a script which get the latest git repo and build them.
#
# Tested under ubuntu 15.04, lower versions don't have PyQT 5.2.1 which is required by cura

cd ~
mkdir -p dev && cd dev

sudo apt-get install -y git cmake cmake-gui autoconf libtool python3-setuptools curl python3-pyqt5.* python3-numpy qml-module-qtquick-controls
curl -L https://github.com/Ultimaker/Cura/archive/15.06.03.tar.gz > Cura.tar.gz
curl -L https://github.com/Ultimaker/Uranium/archive/15.06.03.tar.gz > Uranium.tar.gz
curl -L https://github.com/Ultimaker/CuraEngine/archive/15.06.03.tar.gz > CuraEngine.tar.gz
curl -L https://github.com/Ultimaker/libArcus/archive/15.06.03.tar.gz > libArcus.tar.gz
curl -L https://github.com/Ultimaker/protobuf/archive/15.06.03.tar.gz > protobuf.tar.gz
for file in *.tar.gz; do mkdir -p ${file%%.*}; tar -xvf $file --strip-components=1 -C ${file%%.*}; done

cd protobuf
./autogen.sh
./configure
make -j4
sudo make install
sudo ldconfig
cd python
python3 setup.py build
sudo python3 setup.py install
cd ../..

cd libArcus
mkdir build && cd build
cmake .. -DPYTHON_SITE_PACKAGES_DIR=/usr/lib/python3.4/dist-packages
make -j4
sudo make install
cd ../../

cd CuraEngine
mkdir build && cd build
cmake ..
make -j4
cd ../../

cd Uranium
mkdir build && cd build
cmake .. -DPYTHON_SITE_PACKAGES_DIR=/usr/lib/python3.4/dist-packages -DURANIUM_PLUGINS_DIR=/usr/lib/python3.4/dist-packages
sudo make install
cd ../..

#cp -rv Uranium/resources/* Cura/resources/
ln -s $PWD/Uranium/resources/* Cura/resources/.
ln -s $PWD/Uranium/plugins/* Cura/plugins/.
mkdir bin
ln -s $PWD/CuraEngine/build/CuraEngine bin/CuraEngine
cd Cura
python3 cura_app.py
