#!/bin/bash

## Var start
DEBUG="n"
INSTALL_DIR="/usr/local/bin"
DL_WEB="https://raw.githubusercontent.com/imlaoyou2333/bandwithshareprofit/main"
# PacketStream
INSTALL_PACKETSTREAM="n"
PS_CID="6wV"
# Bitping
INSTALL_BITPING="n"

## Var end

#read Var
for i in "$@"; do
    [ $DEBUG == "y" ] && echo "[DEBUG]typed:"$i 
    [ $i == "help" ] && echo -e "help: \ninfo"
    [[ $i =~ ^install_dir=.*$ ]] && INSTALL_DIR=${i#*install_dir=}
    # packetstream
    [ $i == "packetstream" ] && INSTALL_PACKETSTREAM="y"
    [[ $i =~ ^ps_cid=.*$ ]] && PS_CID=${i#*ps_cid=}
    # bitping
    [ $i == "bitping" ] && INSTALL_BITPING="y"
    [[ $i =~ ^bitping_mail=.*$ ]] && BITPING_MAIL=${i#*bitping_mail=}
    [[ $i =~ ^bitping_pass=.*$ ]] && BITPING_PASS=${i#*bitping_pass=}
done
# Install Packetstream
if [ $INSTALL_PACKETSTREAM == "y" ]
 then
 echo 'We will install Packetstream'
 [ -d $INSTALL_DIR"/psclient/" ] && echo "already exist, remove it" && rm -rf $INSTALL_DIR"/psclient"
 mkdir $INSTALL_DIR"/psclient"
 wget -P $INSTALL_DIR"/psclient/linux_386/" $DL_WEB"/psclient/linux_386/psclient"
 wget -P $INSTALL_DIR"/psclient/linux_amd64/" $DL_WEB"/psclient/linux_amd64/psclient"
 wget -P $INSTALL_DIR"/psclient/linux_arm/" $DL_WEB"/psclient/linux_arm/psclient"
 wget -P $INSTALL_DIR"/psclient/linux_arm64/" $DL_WEB"/psclient/linux_arm64/psclient"
 cat > $INSTALL_DIR"/psclient/pslauncher" <<EOF
#!/bin/sh

arch=\$(uname -m)

# Sleep 10s to prevent tight loop in case of failure
echo "PacketStream client is starting..."
sleep 10

case \$arch in
  x86_64)
    echo "Starting x86_64 client..."
    exec $INSTALL_DIR/psclient/linux_amd64/psclient "\$@"
    ;;
  i386)
    echo "Starting i386 client..."
    exec $INSTALL_DIR/psclient/linux_386/psclient "\$@"
    ;;
  armv6l)
    echo "Starting armv6l client..."
    exec $INSTALL_DIR/psclient/linux_arm/psclient "\$@"
    ;;
  armv7l)
    echo "Starting armv7l client..."
    exec $INSTALL_DIR/psclient/linux_arm/psclient "\$@"
    ;;
  armv8l)
    echo "Starting armv8l client..."
    exec $INSTALL_DIR/psclient/linux_arm/psclient "\$@"
    ;;
  aarch64)
    echo "Starting aarch64 client..."
    # Uses 32-bit binary due to compatibility issues on some devices
    exec $INSTALL_DIR/psclient/linux_arm/psclient "\$@"
    ;;
  *)
    echo "Unsupported architecture: \$arch"
    exit 1
    ;;
esac
EOF
 cat > $INSTALL_DIR/psclient/config <<EOF
PS_IS_DOCKER=true
CID=$PS_CID
EOF
 cat > /usr/lib/systemd/system/psclient.service <<EOF
[Unit]
Description=Packetstream Client
After=network.target

[Service]
Type=simple
EnvironmentFile=$INSTALL_DIR/psclient/config
ExecStart=$INSTALL_DIR/psclient/pslauncher
WorkingDirectory=$INSTALL_DIR/psclient
User=root
Group=root

[Install]
WantedBy = multi-user.target
EOF
 chmod a+x $INSTALL_DIR/psclient/{linux_386,linux_arm,linux_amd64,linux_arm64}/psclient
 chmod a+x $INSTALL_DIR/psclient/pslauncher
 systemctl daemon-reload
 systemctl enable psclient
 systemctl start psclient
 echo "Packetstream done!"
fi

#Install Bitping
if [ $INSTALL_BITPING == "y" ]
 then
 [ -d $INSTALL_DIR"/bitping/" ] && echo "already exist, remove it" && rm -rf $INSTALL_DIR"/bitping"
 wget -P $INSTALL_DIR/bitping https://downloads.bitping.com/node/linux.zip
 unzip -d $INSTALL_DIR/bitping $INSTALL_DIR/bitping/linux.zip
 mv $INSTALL_DIR/bitping/release/bitping-node-amd64-linux $INSTALL_DIR/bitping/
 rm -rf $INSTALL_DIR/bitping/release
 cat > $INSTALL_DIR/bitping/config <<EOF
BITPING_MAIL=$BITPING_MAIL
BITPING_PASS=$BITPING_PASS
EOF
 cat > /usr/lib/systemd/system/bitping-node.service <<EOF
[Unit]
Description=Bitping node
After=network.target

[Service]
Type=simple
EnvironmentFile=$INSTALL_DIR/bitping/config
ExecStart=$INSTALL_DIR/bitping/bitping-node-amd64-linux --email \$BITPING_MAIL --password \$BITPING_PASS --server
WorkingDirectory=$INSTALL_DIR/bitping/
User=root
Group=root

[Install]
WantedBy = multi-user.target
EOF
 systemctl daemon-reload
 systemctl enable bitping-node
 systemctl start bitping-node
 echo "Bitping done!"
fi