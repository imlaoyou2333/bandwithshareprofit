#!/bin/bash

## Var start
DEBUG="n"
INSTALL_DIR=""
DL_WEB="https://raw.githubusercontent.com/imlaoyou2333/bandwithshareprofit/main"
# PacketStream
INSTALL_PACKETSTREAM="n"
PS_CID="6wV"

## Var end

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
 cat > $INSTALL_DIR/psclient/config <<EOF
CID $PS_CID
EOF
 cat > /usr/lib/systemd/system/psclient.service <<EOF
[Unit]
Description=Packetstream Client
After=network.target

[Service]
Type=simple
EnvironmentFile=$INSTALL_DIR/psclient/config
ExecStart=$INSTALL_DIR/psclient/psclient

[Install]
WantedBy = multi-user.target
EOF
 systemctl daemon-reload
 systemctl enable psclient
 systemctl start psclient
 echo "Packetstream done!"
fi