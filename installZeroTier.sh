#!/bin/bash
echo "*******************************************************************************"
echo "This script will install ZeroTier on your Ubuntu Server under the current user:"
echo "$USER"
echo "*******************************************************************************"
read -p "Press any key to continue..."

#Install deps
sudo apt install -y build-essential curl pkg-config libssl-dev 

#rust/cargo (needed for make to build or will fail)
echo " "
echo "*****************************************"
echo "Please choose option 1 when prompted next"
echo "*****************************************"
read -p "Press any key to continue..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

#clone ZT source
git clone https://github.com/zerotier/ZeroTierOne.git


#make it
cd ZeroTierOne
make


#Create service to run at startup
sudo tee $HOME/ZeroTierOne/startZT.sh >/dev/null << EOF
#!/bin/bash
cd $HOME/ZeroTierOne/
sudo ./zerotier-one -d
EOF

sudo chmod +x startZT.sh 

sudo tee /etc/systemd/system/zero-tier.service >/dev/null << EOF
[Unit]
After=network.target
[Service]
ExecStart=$HOME/ZeroTierOne/startZT.sh
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable zero-tier.service
sudo systemctl start zero-tier.service

echo "*****************************************"
echo "All done with install, run this command to verify service is up and active:"
echo " "
echo "sudo systemctl status zero-tier.service"
echo " "
echo "*****************************************"
