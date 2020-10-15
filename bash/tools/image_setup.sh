#!/bin/bash

#####################################################################################
#                                  ADS-B RECEIVER                                   #
#####################################################################################
#                                                                                   #
#  This script is meant only to create offical Raspbian releases for this project.  # 
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                   #
# Copyright (c) 2015-2016 Joseph A. Prochazka                                       #
#                                                                                   #
# Permission is hereby granted, free of charge, to any person obtaining a copy      #
# of this software and associated documentation files (the "Software"), to deal     #
# in the Software without restriction, including without limitation the rights      #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell         #
# copies of the Software, and to permit persons to whom the Software is             #
# furnished to do so, subject to the following conditions:                          #
#                                                                                   #
# The above copyright notice and this permission notice shall be included in all    #
# copies or substantial portions of the Software.                                   #
#                                                                                   #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR        #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,          #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE       #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER            #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,     #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE     #
# SOFTWARE.                                                                         #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


          ################################################################
          ##  THIS SCRIPT IS ONLY MEANT FOR RASPBIAN IMAGE PREPERATION  ##
          ################################################################
          #                                                              #
          # This script must be ran from the projects root directory.    #
          #                                                              #
          # pi@darkstar: ./bash/tools/image_setup.sh                     #
          #                                                              #
          ################################################################


clear

## VARIABLES

RECEIVER_ROOT_DIRECTORY="${PWD}"
RECEIVER_BASH_DIRECTORY="${RECEIVER_ROOT_DIRECTORY}/bash"
RECEIVER_BUILD_DIRECTORY="${RECEIVER_ROOT_DIRECTORY}/build"

## INCLUDE EXTERNAL SCRIPTS

source ${RECEIVER_BASH_DIRECTORY}/variables.sh
source ${RECEIVER_BASH_DIRECTORY}/functions.sh

echo -e ""
echo -e "\e[91m  The ADS-B Receiver Project Image Preparation Script\e[97m"
echo -e ""

## UPDATE REPOSITORY LISTS AND OPERATING SYSTEM

echo -e "\e[95m  Updating repository lists and operating system...\e[97m"
echo -e ""
sudo apt-get update
sudo apt-get -y dist-upgrade

## INSTALL DUMP1090

echo -e ""
echo -e "\e[95m  Installing prerequisite packages...\e[97m"
echo -e ""
CheckPackage git
CheckPackage curl
CheckPackage build-essential
CheckPackage debhelper
CheckPackage cron
CheckPackage rtl-sdr
CheckPackage librtlsdr-dev
CheckPackage libusb-1.0-0-dev
CheckPackage pkg-config
CheckPackage lighttpd
CheckPackage fakeroot
CheckPackage bc

## SETUP RTL-SDR RULES

echo -e "\e[95m  Setting up RTL-SDR udev rules...\e[97m"
sudo curl --http1.1 https://raw.githubusercontent.com/osmocom/rtl-sdr/master/rtl-sdr.rules --output /etc/udev/rules.d/rtl-sdr.rules
sudo service udev restart
BlacklistModules

# Ask which version of dump1090 to install.
DUMP1090OPTION=$(whiptail --backtitle "${RECEIVER_PROJECT_TITLE}" --title "Choose Dump1090 Version" --menu "Which version of dump1090 is to be installed?" 12 65 2 "dump1090-mutability" "(Mutability)" "dump1090-fa" "(FlightAware)" 3>&1 1>&2 2>&3)

case ${DUMP1090OPTION} in
    "dump1090-mutability")
        echo -e "\e[95m  Installing dump1090-mutability...\e[97m"
        echo -e ""

        # Dump1090-mutability
        echo -e ""
        echo -e "\e[95m  Installing dump1090-mutability...\e[97m"
        echo -e ""
        mkdir -vp ${RECEIVER_BUILD_DIRECTORY}/dump1090-mutability
        cd ${RECEIVER_BUILD_DIRECTORY}/dump1090-mutability 2>&1
        git clone https://github.com/mutability/dump1090.git
        cd ${RECEIVER_BUILD_DIRECTORY}/dump1090-mutability/dump1090 2>&1
        dpkg-buildpackage -b
        cd ${RECEIVER_BUILD_DIRECTORY}/dump1090-mutability 2>&1
        sudo dpkg -i dump1090-mutability_1.15~dev_*.deb
        ;;
    "dump1090-fa")
        echo -e "\e[95m  Installing dump1090-fa and PiAware...\e[97m"
        echo -e ""

        # Install prerequisite packages.
        echo -e "\e[95m  Installing additional dump1090-fa and PiAware prerequisite packages...\e[97m"
        echo -e ""
        CheckPackage dh-systemd
        CheckPackage libncurses5-dev
        CheckPackage cmake
        CheckPackage doxygen
        CheckPackage libtecla-dev
        CheckPackage help2man
        CheckPackage pandoc
        CheckPackage tcl8.6-dev
        CheckPackage autoconf
        CheckPackage python3-dev
        CheckPackage python3-venv
        CheckPackage virtualenv
        CheckPackage zlib1g-dev
        CheckPackage tclx8.4
        CheckPackage tcllib
        CheckPackage tcl-tls
        CheckPackage itcl3
        CheckPackage net-tools
        CheckPackage devscripts
        CheckPackage libhackrf-dev
        CheckPackage liblimesuite-dev

        # bladeRF
        echo ""
        echo -e "\e[95m  Installing bladeRF...\e[97m"
        echo ""
        mkdir -vp ${RECEIVER_BUILD_DIRECTORY}/bladeRF
        cd ${RECEIVER_BUILD_DIRECTORY}/bladeRF 2>&1
        git clone https://github.com/Nuand/bladeRF.git
        cd ${RECEIVER_BUILD_DIRECTORY}/bladeRF/bladeRF 2>&1
        dpkg-buildpackage -b
        cd ${RECEIVER_BUILD_DIRECTORY}/bladeRF 2>&1
        sudo dpkg -i libbladerf1_*.deb
        sudo dpkg -i libbladerf-dev_*.deb
        sudo dpkg -i libbladerf-udev_*.deb

        # Dump1090-fa
        echo -e ""
        echo -e "\e[95m  Installing dump1090-fa...\e[97m"
        echo -e ""
        mkdir -vp ${RECEIVER_BUILD_DIRECTORY}/dump1090-fa
        cd ${RECEIVER_BUILD_DIRECTORY}/dump1090-fa 2>&1
        git clone https://github.com/flightaware/dump1090.git
        cd ${RECEIVER_BUILD_DIRECTORY}/dump1090-fa/dump1090 2>&1
        dpkg-buildpackage -b
        cd ${RECEIVER_BUILD_DIRECTORY}/dump1090-fa 2>&1
        sudo dpkg -i dump1090-fa_*.deb

        # PiAware
        cd ${RECEIVER_BUILD_DIRECTORY} 2>&1
        git clone https://github.com/flightaware/piaware_builder.git
        cd ${RECEIVER_BUILD_DIRECTORY}/piaware_builder 2>&1
        ./sensible-build.sh jessie
        cd ${RECEIVER_BUILD_DIRECTORY}/piaware_builder/package-jessie 2>&1
        dpkg-buildpackage -b
        sudo dpkg -i ${RECEIVER_BUILD_DIRECTORY}/piaware_builder/piaware_*.deb
        ;;
    *)
        # Nothing selected.
        exit 1
        ;;
esac

## INSTALL THE BASE PORTAL PREREQUISITES PACKAGES

echo -e ""
echo -e "\e[95m  Installing packages needed by the ADS-B Receiver Project Web Portal...\e[97m"
echo -e ""
CheckPackage lighttpd
CheckPackage collectd-core
CheckPackage rrdtool
CheckPackage libpython2.7
CheckPackage php7.0-cgi
CheckPackage php7.0-json

## PREVIOUS LOCALE SCRIPTING THAT SET LOCALE NO LONGER WORKS PROPERLY ON STRETCH.
## The scripting setting this using this script has been removed for now.
## We will manually set this using rasp-config when creating the script in the meantime.
## Later I will look into automating this but time is short on the v2.6.0 release.

## TOUCH THE IMAGE FILE

echo -e "\e[95m  Touching the \"image\" file...\e[97m"
cd ${RECEIVER_ROOT_DIRECTORY} 2>&1
touch image

## CHANGE THE PASSWORD FOR THE USER PI

echo -e "\e[95m  Changing the password for the user pi...\e[97m"
echo "pi:adsbreceiver" | sudo chpasswd

## ENABLE SSH

echo -e "\e[95m  Touching the \"ssh\" file...\e[97m"
sudo touch /boot/ssh
echo -e "\e[95m  Reconfiguring openssh-server...\e[97m"
sudo rm -f /etc/ssh/ssh_host_* && sudo dpkg-reconfigure openssh-server

## CLEAR BASH HISTORY

history -c && history -w

## DONE

echo -e ""
echo -e "\e[91m  Image preparation completed.)\e[39m"
echo -e "\e[91m  Device will be shut down in 5 seconds.\e[39m"
echo -e ""

sleep 5
sudo halt

exit 0
