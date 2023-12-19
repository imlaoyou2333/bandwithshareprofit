#!/bin/bash

##Var start
DEBUG="n"
INSTALL_DIR=""
DL_WEB="https://raw.githubusercontent.com/imlaoyou2333/bandwithshareprofit/main"
INSTALL_PACKETSTREAM="n"
#read Var
for i in "$@"; do
    [ $DEBUG == "y" ] && echo "[DEBUG]typed:"$i
    [ $i == "help" ] && echo -e "help: \ninfo"
    [ $i == "packetstream" ] && INSTALL_PACKETSTREAM="y"
done
if [ $INSTALL_PACKETSTREAM == "y" ]
 then
 echo 'We will install Packetstream'
 [ -d $INSTALL_DIR"/psclient/" ] && echo "already exist, remove it" && rm -rf $INSTALL_DIR"/psclient"
 mkdir $INSTALL_DIR"/psclient"
 wget -P $INSTALL_DIR"/psclient/" $DL_WEB"/psclient/pslauncher"
 wget -P $INSTALL_DIR"/psclient/linux_386/" $DL_WEB"/psclient/linux_386/psclient"
 wget -P $INSTALL_DIR"/psclient/linux_amd64/" $DL_WEB"/psclient/linux_amd64/psclient"
 wget -P $INSTALL_DIR"/psclient/linux_arm/" $DL_WEB"/psclient/linux_arm/psclient"
 wget -P $INSTALL_DIR"/psclient/linux_arm64/" $DL_WEB"/psclient/linux_arm64/psclient"
fi