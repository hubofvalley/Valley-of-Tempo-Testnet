#!/bin/bash

set -e

# ==== CONFIG ====
echo -e "\n--- Tempo Testnet Node Setup ---"

LOGO="
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

echo "$LOGO"

# Prompt for MONIKER and TEMPO_PORT
read -p "Enter your moniker: " MONIKER
read -p "Enter your preferred port number: (leave empty to use default: 30) " TEMPO_PORT
if [ -z "$TEMPO_PORT" ]; then
    TEMPO_PORT=30
fi
read -p "Configure UFW firewall rules for Tempo? (y/n): " SETUP_UFW

# Stop and remove existing Tempo node
sudo systemctl daemon-reload
sudo systemctl stop tempo 2>/dev/null || true
sudo systemctl disable tempo 2>/dev/null || true
sudo rm -rf /etc/systemd/system/tempo.service 2>/dev/null || true
sudo rm -rf $HOME/.tempo 2>/dev/null || true
sed -i "/TEMPO_/d" $HOME/.bash_profile 2>/dev/null || true

# 1. Install dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev

# 2. Set environment variables
touch "$HOME/.bash_profile"
export MONIKER=$MONIKER
export TEMPO_CHAIN_ID="andantino"
export TEMPO_PORT=$TEMPO_PORT
export TEMPO_HOME="$HOME/.tempo"

echo "export MONIKER=\"$MONIKER\"" >> $HOME/.bash_profile
echo "export TEMPO_CHAIN_ID=\"andantino\"" >> $HOME/.bash_profile
echo "export TEMPO_PORT=\"$TEMPO_PORT\"" >> $HOME/.bash_profile
echo "export TEMPO_HOME=\"$HOME/.tempo\"" >> $HOME/.bash_profile
echo "export PATH=\$PATH:$HOME/.tempo/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Optional: Configure UFW based on chosen ports
if [[ "$SETUP_UFW" =~ ^[Yy]$ ]]; then
    sudo apt install -y ufw
    sudo ufw allow ssh
    sudo ufw allow ${TEMPO_PORT}303/tcp
    sudo ufw allow ${TEMPO_PORT}303/udp
    sudo ufw allow ${TEMPO_PORT}545/tcp
    sudo ufw allow ${TEMPO_PORT}546/tcp
    sudo ufw allow ${TEMPO_PORT}900/tcp
    sudo ufw --force enable
    sudo ufw status verbose
fi

# 3. Install Tempo binary
curl -L https://tempo.xyz/install | bash

touch ~/.bash_profile
if [ -f ~/.bashrc ]; then
  grep -E "tempo|Tempo|\\.tempo" ~/.bashrc >> ~/.bash_profile || true
  sed -i.bak '/tempo\|Tempo\|\.tempo/d' ~/.bashrc
fi

# Install Foundry (store env in .bash_profile just like Tempo)
curl -L https://foundry.paradigm.xyz | bash

if [ -f ~/.bashrc ]; then
  grep -E "foundry|Foundry|\\.foundry" ~/.bashrc >> ~/.bash_profile || true
  sed -i.bak '/foundry\|Foundry\|\.foundry/d' ~/.bashrc
fi

if ! grep -q ".foundry/bin" ~/.bash_profile; then
  echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.bash_profile
fi

source ~/.bash_profile
~/.foundry/bin/foundryup
source ~/.bash_profile
tempo --version
cast --version

# 4. Create data directory and download snapshot
mkdir -p "$TEMPO_HOME/data"
tempo download

# 5. Create systemd service file
sudo tee /etc/systemd/system/tempo.service > /dev/null <<EOF
[Unit]
Description=Tempo Node (Reth stack)
After=network.target
Wants=network.target

[Service]
Type=simple
User=$USER
Group=$USER
Environment=RUST_LOG=info
WorkingDirectory=$HOME/.tempo
ExecStart=$HOME/.tempo/bin/tempo node \
  --datadir $HOME/.tempo/data \
  --follow \
  --port ${TEMPO_PORT}303 \
  --discovery.addr 0.0.0.0 \
  --discovery.port ${TEMPO_PORT}303 \
  --http \
  --http.addr 0.0.0.0 \
  --http.port ${TEMPO_PORT}545 \
  --http.api eth,net,web3,txpool,trace \
  --metrics ${TEMPO_PORT}900 \
  --full \
  --prune.block-interval 2500 \
  --prune.sender-recovery.full \
  --prune.receipts.distance 10064 \
  --prune.account-history.distance 10064 \
  --prune.storage-history.distance 10064
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=tempo
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# 6. Start the node
sudo systemctl daemon-reload
sudo systemctl enable tempo
sudo systemctl restart tempo

# 7. Confirmation message for installation completion
if systemctl is-active --quiet tempo; then
    echo "Tempo node installation and service started successfully!"
else
    echo "Tempo node installation failed. Please check the logs for more information."
fi

# show the full logs
echo "sudo journalctl -u tempo -fn 100"
