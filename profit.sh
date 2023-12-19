#!/bin/bash

##Var start
DEBUG="0"
INSTALL_DIR=""
DL_WEB=""
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
 
fi