#!/bin/bash

## Var start
DEBUG="n"
INSTALL_DIR="/usr/local/bin"
DL_WEB=""
#PacketStream
INSTALL_PACKETSTREAM="n"
# PS_CID=""
# Bitping
INSTALL_BITPING="n"
#Traffmonetizer
INSTALL_TRAFFMONETIZER="n"
# TRAFFMONETIZER_TOKEN=""
#EarnFM
INSTALL_EARNFM="n"
# EARNFM_TOKEN=""
#ProxyLite
INSTALL_PROXYLITE="n"
PROXYLITE_TOKEN=""
#Proxyrack
INSTALL_PROXYRACK="n"
PROXYRACK_UUID=""
## Var end

#Help
for i in "$@"; do
[ $i == "help" ] && echo -e "Bandwidthshare auto config tool without Docker. For tiny tiny VPS (especially low RAM NAT VPS).\nUsage: profit.sh project1 project2... config1=value1 config2=value2...\nExample: ./profit.sh proxylite proxyrack --proxylite_token=token  --proxyrack_token=token\nFor now support:\nBitping:\nbitping_mail=\nbitping_pass=\nProxyLite:\nproxylite_token=\nProxyrack:\nproxyrack_token=\n" && exit 0
done

#read Var
for i in "$@"; do
    [ $DEBUG == "y" ] && echo "[DEBUG]typed:"$i 
    [[ $i =~ ^install_dir=.*$ ]] && INSTALL_DIR=${i#*install_dir=}
    # packetstream
    # [ $i == "packetstream" ] && INSTALL_PACKETSTREAM="y"
    # [[ $i =~ ^ps_cid=.*$ ]] && PS_CID=${i#*ps_cid=}
    # bitping
    [ $i == "bitping" ] && INSTALL_BITPING="y"
    [[ $i =~ ^bitping_mail=.*$ ]] && BITPING_MAIL=${i#*bitping_mail=}
    [[ $i =~ ^bitping_pass=.*$ ]] && BITPING_PASS=${i#*bitping_pass=}
    # traffmotizer
    # [ $i == "traffmonetizer" ] && INSTALL_TRAFFMONETIZER="y"
    # [[ $i =~ ^traffmonetizer_token=.*$ ]] && TRAFFMONETIZER_TOKEN=${i#*traffmonetizer_token=}
    # EarnFM
    # [ $i == "earnfm" ] && INSTALL_EARNFM="y"
    # [[ $i =~ ^earnfm_token=.*$ ]] && EARNFM_TOKEN=${i#*earnfm_token=}
    # ProxyLite
    [ $i == "proxylite" ] && INSTALL_PROXYLITE="y"
    [[ $i =~ ^proxylite_token=.*$ ]] && PROXYLITE_TOKEN=${i#*proxylite_token=}
    # proxyrack
    [ $i == "proxyrack" ] && INSTALL_PROXYRACK="y"
    [[ $i =~ ^proxyrack_token=.*$ ]] && PROXYRACK_UUID=${i#*proxyrack_UUID=}
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

# Install Traffmonetizer
if [ $INSTALL_TRAFFMONETIZER == "y" ]
 then
 [ -d $INSTALL_DIR"/traffmonetizer/" ] && echo "already exist, remove it" && rm -rf $INSTALL_DIR"/traffmonetizer"
 wget -P $INSTALL_DIR"/traffmonetizer/" $DL_WEB"/traffmonetizer/Cli"
 cat > $INSTALL_DIR/traffmonetizer/config <<EOF
ASPNETCORE_URLS=http://+:80
DOTNET_RUNNING_IN_CONTAINER=true
DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
DOTNET_CLI_TELEMETRY_OPTOUT=1
TRAFFMONETIZER_TOKEN=$TRAFFMONETIZER_TOKEN
EOF
 cat > /usr/lib/systemd/system/traffmonetizer.service <<EOF
[Unit]
Description=Traffmonetizer Cli
After=network.target

[Service]
Type=simple
EnvironmentFile=$INSTALL_DIR/traffmonetizer/config
ExecStart=$INSTALL_DIR/traffmonetizer/Cli start accept --token $TRAFFMONETIZER_TOKEN
WorkingDirectory=$INSTALL_DIR/traffmonetizer/
User=root
Group=root

[Install]
WantedBy = multi-user.target
EOF
systemctl daemon-reload
systemctl enable traffmonetizer
systemctl start traffmonetizer
echo "Traffmonetizer done!"
fi

#Install EarnFM
if [ $INSTALL_EARNFM == "y" ]
 then
 [ -d $INSTALL_DIR"/earnfm/" ] && echo "already exist, remove it" && rm -rf $INSTALL_DIR"/earnfm"
 wget -P $INSTALL_DIR"/earnfm/" $DL_WEB"/earnfm/earnfm_example"
 cat > $INSTALL_DIR/earnfm/config <<EOF
EARNFM_TOKEN=$EARNFM_TOKEN
EOF
 cat > /usr/lib/systemd/system/earnfm.service <<EOF
[Unit]
Description=EarnFM Cli
After=network.target

[Service]
Type=simple
EnvironmentFile=$INSTALL_DIR/earnfm/config
ExecStart=$INSTALL_DIR/earnfm/earnfm_example
WorkingDirectory=$INSTALL_DIR/earnfm/
User=root
Group=root

[Install]
WantedBy = multi-user.target
EOF
 systemctl daemon-reload
 systemctl enable earnfm
 systemctl start earnfm
 echo "EarnFM done!"
fi

# Install ProxyLite
if [ $INSTALL_PROXYLITE == "y" ]
 then
 echo "Checking ProxyLite Installation";

if ! [[ -d $INSTALL_DIR/proxylite ]]; then
	echo "Creating folders";
	
	mkdir $INSTALL_DIR/proxylite
	mkdir $INSTALL_DIR/proxylite/dotnet60
	mkdir $INSTALL_DIR/proxylite/service
	echo $PROXYLITE_TOKEN > $INSTALL_DIR/proxylite/service/userid.ini
	
	echo "Downloading .NET 6.0"
	wget https://app.proxylite.ru/thirdparty/dotnet-runtime-6.0.10-linux-x64.tar.gz -P $INSTALL_DIR/proxylite/dotnet60 2> /dev/null 1>/dev/null
	echo "Downloading ProxyService"
	wget https://app.proxylite.ru/netcoreapp-latest.tar -P $INSTALL_DIR/proxylite/service 2> /dev/null 1>/dev/null
	echo "Unpacking .NET 6.0"
	tar xf $INSTALL_DIR/proxylite/dotnet60/dotnet-runtime-6.0.10-linux-x64.tar.gz -C $INSTALL_DIR/proxylite/dotnet60
	rm $INSTALL_DIR/proxylite/dotnet60/dotnet-runtime-6.0.10-linux-x64.tar.gz
	chmod +x $INSTALL_DIR/proxylite/dotnet60/dotnet
	echo "Unpacking ProxyService"
	tar xf $INSTALL_DIR/proxylite/service/netcoreapp-latest.tar -C $INSTALL_DIR/proxylite/service
	rm $INSTALL_DIR/proxylite/service/netcoreapp-latest.tar
	
	echo "Creating systemd daemon"
	cat > /etc/systemd/system/proxylite.service <<EOF
[Unit]
Description=ProxyLite ProxyService
After=network.target

[Service]
StartLimitInterval=0
StandardOutput=null
LimitNOFILE=1008575
Restart=always
RestartSec=8
WorkingDirectory=$INSTALL_DIR/proxylite/service
ExecStart=$INSTALL_DIR/proxylite/dotnet60/dotnet $INSTALL_DIR/proxylite/service/ProxyService.Core.dll

[Install]
WantedBy=multi-user.target
EOF
	echo "Reloading systemd daemons"
	systemctl daemon-reload
	echo "Enabling ProxyLite daemon"
	systemctl enable proxylite
	echo "Starting ProxyLite daemon"
	systemctl start proxylite
	
	echo "Successfily! You are installed ProxyLite on this system. You can check install by 'systemctl status proxylite'"
	echo "If you want stop ProxyLite, you can use 'systemctl stop proxylite'"
	echo "If you want remove ProxyLite, you should start this script with 'uninstall' argument"
	
else
	echo "ProxyLite already installed";
	$PROXYLITE_CURRENT_ID=$(cat $INSTALL_DIR/proxylite/service/userid.ini);
	
	if [[ $PROXYLITE_CURRENT_ID != $PROXYLITE_TOKEN ]]; then
		echo "Presented ID $PROXYLITE_TOKEN is not match by current $PROXYLITE_CURRENT_ID";
		echo "Restarting service";
		echo $PROXYLITE_TOKEN > $INSTALL_DIR/proxylite/service/userid.ini
		systemctl restart proxylite
		
	fi
fi
echo "ProxyLite Done!"
fi

if [ $INSTALL_PROXYRACK == "y" ]
then
 [ -d $INSTALL_DIR"/proxyrack/" ] && echo "already exist, remove it" && rm -rf $INSTALL_DIR"/proxyrack"
 if [ -z "$UUID" ]; then
    PROXYRACK_UUID=$(cat /dev/urandom | LC_ALL=C tr -dc 'A-F0-9' | dd bs=1 count=64 2>/dev/null && echo)
    echo "Your Proxyrack UUID is $PROXYRACK_UUID"
    wget https://app-updates.sock.sh/peerclient/script/script.js -o $INSTALL_DIR/proxyrack/
 fi
 apt install -y nodejs npm
 cat > $INSTALL_DIR/proxyrack/config <<EOF
UUID=$PROXYRACK_UUID
EOF
 cat > /usr/lib/systemd/system/proxyrack.service <<EOF
[Unit]
Description=Proxyrack Point Of Presence
After=network.target

[Service]
Type=simple
EnvironmentFile=$INSTALL_DIR/proxyrack/config
ExecStart=node script.js --homeIp point-of-presence.sock.sh --homePort 443 --id \$UUID --version $(curl --silent https://app-updates.sock.sh/peerclient/script/version.txt) --clientKey proxyrack-pop-client --clientType PoP
WorkingDirectory=$INSTALL_DIR/proxyrack/
User=root
Group=root

[Install]
WantedBy = multi-user.target
EOF
systemctl daemon-reload
systemctl enable proxyrack
systemctl start proxyrack
echo "Proxyrack done!"
fi