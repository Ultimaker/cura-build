#Set path to Arduino headers and compilers and such.
ARDUINO_PATH=/usr/share/arduino
PATH=${ARDUINO_PATH}/hardware/tools/avr/bin:${ARDUINO_PATH}/hardware/tools/avr/tools/bin:$PATH
ARDUINO_VERSION=105
CURA_VERSION=2.3

#Get the cura-binary-data repository to push updated firmware to (always clean pull).
rm -rf cura-binary-data
git clone git@github.com:Ultimaker/cura-binary-data.git
cd cura-binary-data
git checkout master #TODO: Set this properly?
git pull #Just to be sure, in case the repository already existed.
rm cura/resources/firmware/commit-ids.txt #Reset these files.
rm cura/resources/firmware/sha1hashes.txt
cd ..

#Helper functions.

# $1: Name of the target hex file, without extension.
# $2: Repository name (within Ultimaker's account), without extension.
# $3: Branch name.
# $4: Motherboard number to make for.
# $5: Defines to make with (VERSION_PROFILE, BAUDRATE, etc). All in one string of key=value pairs. With quotation marks if you like!
function makeAndCopy
{
    echo "Building $1.hex"
    rm -rf build/$1 #Remove any old build objects.
    mkdir build/$1
    git clone https://github.com/Ultimaker/$2.git
    cd $2
    git checkout $3
    git pull #Just to be sure.
    cd Marlin
    make HARDWARE_MOTHERBOARD=$4 ARDUINO_INSTALL_DIR=${ARDUINO_PATH} ARDUINO_VERSION=${ARDUINO_VERSION} BUILD_DIR=../../build/$1 DEFINES="$5"
    #make HARDWARE_MOTHERBOARD=$4 BUILD_DIR=../../build/$1 DEFINES=$5
    commitid="$(git rev-parse HEAD)"
    echo $1: $commitid >> ../../cura-binary-data/cura/resources/firmware/commit-ids.txt
    cd ../..
    cp build/$1/Marlin.hex cura-binary-data/cura/resources/firmware/$1.hex
    sha1sum build/$1/Marlin.hex >> cura-binary-data/cura/resources/firmware/sha1hashes.txt
}

#Building the actual firmware!

#Ultimaker Original
makeAndCopy MarlinUltimaker-115200 Marlin Marlin_v1 7 "'VERSION_BASE=\"Ultimaker:_${CURA_VERSION}\"' 'VERSION_PROFILE=\"115200_single\"' BAUDRATE=115200 TEMP_SENSOR_1=0 EXTRUDERS=1"
makeAndCopy MarlinUltimaker-250000 Marlin Marlin_v1 7 "'VERSION_BASE=\"Ultimaker:_${CURA_VERSION}\"' 'VERSION_PROFILE=\"250000_single\"' BAUDRATE=250000 TEMP_SENSOR_1=0 EXTRUDERS=1"
makeAndCopy MarlinUltimaker-115200-dual Marlin Marlin_v1 7 "'VERSION_BASE=\"Ultimaker:_${CURA_VERSION}\"' 'VERSION_PROFILE=\"115200_dual\"' BAUDRATE=115200 TEMP_SENSOR_1=-1 EXTRUDERS=2"
makeAndCopy MarlinUltimaker-250000-dual Marlin Marlin_v1 7 "'VERSION_BASE=\"Ultimaker:_${CURA_VERSION}\"' 'VERSION_PROFILE=\"250000_dual\"' BAUDRATE=250000 TEMP_SENSOR_1=-1 EXTRUDERS=2"
makeAndCopy MarlinUltimaker-HBK-115200 Marlin Marlin_UM_HeatedBedUpgrade 7 "'VERSION_BASE=\"Ultimaker:_${CURA_VERSION}\"' 'VERSION_PROFILE=\"115200_single_HB\"' BAUDRATE=115200 TEMP_SENSOR_1=0 EXTRUDERS=1"
makeAndCopy MarlinUltimaker-HBK-250000 Marlin Marlin_UM_HeatedBedUpgrade 7 "'VERSION_BASE=\"Ultimaker:_${CURA_VERSION}\"' 'VERSION_PROFILE=\"250000_single_HB\"' BAUDRATE=250000 TEMP_SENSOR_1=0 EXTRUDERS=1"
makeAndCopy MarlinUltimaker-HBK-115200-dual Marlin Marlin_UM_HeatedBedUpgrade 7 "'VERSION_BASE=\"Ultimaker:_${CURA_VERSION}\"' 'VERSION_PROFILE=\"115200_dual_HB\"' BAUDRATE=115200 TEMP_SENSOR_1=-1 EXTRUDERS=2"
makeAndCopy MarlinUltimaker-HBK-250000-dual Marlin Marlin_UM_HeatedBedUpgrade 7 "'VERSION_BASE=\"Ultimaker:_${CURA_VERSION}\"' 'VERSION_PROFILE=\"250000_dual_HB\"' BAUDRATE=250000 TEMP_SENSOR_1=-1 EXTRUDERS=2"

#Ultimaker Original+
makeAndCopy MarlinUltimaker-UMOP-250000 Marlin Marlin_UM_Original_Plus 72 "'VERSION_PROFILE=\"250000_single\"' BAUDRATE=250000 TEMP_SENSOR_1=0 EXTRUDERS=1"
makeAndCopy MarlinUltimaker-UMOP-115200 Marlin Marlin_UM_Original_Plus 72 "'VERSION_PROFILE=\"115200_single\"' BAUDRATE=115200 TEMP_SENSOR_1=0 EXTRUDERS=1"
makeAndCopy MarlinUltimaker-UMOP-250000-dual Marlin Marlin_UM_Original_Plus 72 "'VERSION_PROFILE=\"250000_dual\"' BAUDRATE=250000 TEMP_SENSOR_1=-1 EXTRUDERS=2"
makeAndCopy MarlinUltimaker-UMOP-115200-dual Marlin Marlin_UM_Original_Plus 72 "'VERSION_PROFILE=\"115200_dual\"' BAUDRATE=115200 TEMP_SENSOR_1=-1 EXTRUDERS=2"

#Ultimaker 2
makeAndCopy MarlinUltimaker2 Ultimaker2Marlin master 72 "'STRING_CONFIG_H_AUTHOR=\"Vers:_${CURA_VERSION}\"' TEMP_SENSOR_1=0 EXTRUDERS=1"
makeAndCopy MarlinUltimaker2-dual Ultimaker2Marlin master 72 "'STRING_CONFIG_H_AUTHOR=\"Vers:_${CURA_VERSION}\"' TEMP_SENSOR_1=20 EXTRUDERS=2"

#Ultimaker 2 Go
makeAndCopy MarlinUltimaker2go Ultimaker2Marlin UM2go 72 "'STRING_CONFIG_H_AUTHOR=\"Vers:_${CURA_VERSION}go\"' TEMP_SENSOR_1=0 EXTRUDERS=1"

#Ultimaker 2 Extended
makeAndCopy MarlinUltimaker2extended Ultimaker2Marlin UM2extended 72 "'STRING_CONFIG_H_AUTHOR=\"Vers:_${CURA_VERSION}ex\"' TEMP_SENSOR_1=0 EXTRUDERS=1"
makeAndCopy MarlinUltimaker2extended-dual Ultimaker2Marlin UM2extended 72 "'STRING_CONFIG_H_AUTHOR=\"Vers:_${CURA_VERSION}ex\"' TEMP_SENSOR_1=20 EXTRUDERS=2"

#Ultimaker 2+
makeAndCopy MarlinUltimaker2plus UM2.1-Firmware UM2.1_JarJar 72 "'STRING_CONFIG_H_AUTHOR=\"Vers:_${CURA_VERSION}\"' TEMP_SENSOR_1=0 EXTRUDERS=1"

#Ultimaker 2 Extended+
makeAndCopy MarlinUltimaker2extended-plus UM2.1-Firmware UM2.1_JarJarExtended 72 "'STRING_CONFIG_H_AUTHOR=\"Vers:_${CURA_VERSION}ex\"' TEMP_SENSOR_1=0 EXTRUDERS=1"

