#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

read -p "Are you sure you want to remove the Andantino node and proceed with migration? (yes/no): " CONFIRM_DELETE
if [[ "${CONFIRM_DELETE,,}" != "yes" ]]; then
  echo "Migration cancelled by user."
  exit 0
fi

read -p "Apply official Tempo Moderato snapshot? (Y/n): " USE_SNAPSHOT
if [[ "$USE_SNAPSHOT" =~ ^[Nn]$ ]]; then
  USE_SNAPSHOT=false
else
  USE_SNAPSHOT=true
fi

read -p "Run node as pruned or archive? (p=pruned, a=archive) [p]: " NODE_MODE
if [[ "$NODE_MODE" =~ ^[Aa]$ ]]; then
  NODE_MODE="archive"
else
  NODE_MODE="pruned"
fi

read -p "Enter your preferred port number (default: 30): " TEMPO_PORT
if [ -z "$TEMPO_PORT" ]; then
  TEMPO_PORT=30
fi

# Stop node and delete database
sudo systemctl daemon-reload
sudo systemctl stop tempo 2>/dev/null || true
echo "Deleting old database: $HOME/.tempo/data"
sudo rm -rf "$HOME/.tempo/data"
mkdir -p "$HOME/.tempo/data"

# Update Tempo binary
export PATH="$HOME/.tempo/bin:$PATH"
tempoup -i v1.0.0-rc.1

# Replace systemd service file
sudo rm -f /etc/systemd/system/tempo.service
if [ "$NODE_MODE" = "archive" ]; then
  sudo tee /etc/systemd/system/tempo.service > /dev/null <<EOF
[Unit]
Description=Tempo Node (Reth stack)
After=network.target
Wants=network.target

[Service]
Type=simple
User=${USER}
WorkingDirectory=${HOME}/.tempo
Environment=RUST_LOG=info
ExecStart=${HOME}/.tempo/bin/tempo node \
  --datadir ${HOME}/.tempo/data \
  --follow wss://rpc.moderato.tempo.xyz \
  --port ${TEMPO_PORT}303 \
  --discovery.addr 0.0.0.0 \
  --discovery.port ${TEMPO_PORT}303 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port ${TEMPO_PORT}545 \
  --http.api eth,net,web3,txpool,trace \
  --ws.addr 127.0.0.1 \
  --ws.port ${TEMPO_PORT}546 \
  --authrpc.addr 127.0.0.1 \
  --authrpc.port ${TEMPO_PORT}551 \
  --metrics ${TEMPO_PORT}900
StandardOutput=journal
StandardError=journal
Restart=always
RestartSec=10
SyslogIdentifier=tempo
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF
else
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
  --follow wss://rpc.moderato.tempo.xyz \
  --port ${TEMPO_PORT}303 \
  --discovery.addr 0.0.0.0 \
  --discovery.port ${TEMPO_PORT}303 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port ${TEMPO_PORT}545 \
  --http.api eth,net,web3,txpool,trace \
  --ws.addr 127.0.0.1 \
  --ws.port ${TEMPO_PORT}546 \
  --authrpc.addr 127.0.0.1 \
  --authrpc.port ${TEMPO_PORT}551 \
  --metrics $(curl -4 -s ifconfig.me):${TEMPO_PORT}900 \
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
fi

# Apply snapshot if selected
if [ "$USE_SNAPSHOT" = true ]; then
  tempo download
else
  echo "Skipping snapshot download; node will sync from genesis."
fi

# Start the node
sudo systemctl daemon-reload
sudo systemctl enable tempo
sudo systemctl restart tempo

if systemctl is-active --quiet tempo; then
  echo -e "${GREEN}Migration completed. tempo.service is running.${RESET}"
else
  echo -e "${RED}Migration completed, but tempo.service is not running.${RESET}"
  echo "Check logs: sudo journalctl -u tempo -fn 100"
fi

# Back to Valley of Tempo menu
if declare -f menu >/dev/null 2>&1; then
  menu
else
  echo "Back to the Valley of Tempo main menu: run ./resources/valleyofTempo.sh"
fi
