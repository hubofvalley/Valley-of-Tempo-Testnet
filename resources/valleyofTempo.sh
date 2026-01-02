#!/usr/bin/env bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
ORANGE='\033[38;5;214m'
RESET='\033[0m'

LOGO="
 __      __   _ _                     __   _______                         
 \ \    / /  | | |                   / _| |__   __|                        
  \ \  / /_ _| | | ___ _   _    ___ | |_     | | ___ _ __ ___  _ __   ___  
  _\ \/ / _  | | |/ _ \ | | |  / _ \|  _|    | |/ _ \  _   _ \| '_ \ / _ \ 
 | |\  / (_| | | |  __/ |_| | | (_) | |      | |  __/ | | | | | |_) | (_) |
 | |_\/ \__,_|_|_|\___|\__, |  \___/|_|      |_|\___|_| |_| |_| .__/ \___/ 
 | '_ \| | | |          __/ |                                 | |          
 | |_) | |_| |         |___/                                  |_|          
 |_.__/ \__, |                                                             
         __/ |                                                             
        |___/                                                              
"

INTRO="
Valley of Tempo by Grand Valley

${GREEN}Tempo Node System Requirements${RESET}
${YELLOW}| Category  | Requirements     |
| --------- | ---------------- |
| CPU       | 8+ cores         |
| RAM       | 32+ GB           |
| Storage   | 500+ GB NVMe SSD |
| Bandwidth | 1 GBit/s         |${RESET}

- service file name: ${CYAN}tempo.service${RESET}
- current chain: ${CYAN}andantino (Tempo Testnet)${RESET}
- current chain ID: ${CYAN}42429${RESET}
- current tempo binary version: ${CYAN}0.7.5${RESET}
- Build Timestamp: ${CYAN}2025-12-15T16:14:58.647380962Z${RESET}
- Build Features: ${CYAN}asm_keccak,default,jemalloc,otlp${RESET}
- Build Profile: ${CYAN}maxperf${RESET}
"

PRIVACY_SAFETY_STATEMENT="
${YELLOW}Privacy and Safety Statement${RESET}

${GREEN}No User Data Stored Externally${RESET}
- This script does not store any user data externally. All operations are performed locally on your machine.

${GREEN}No Phishing Links${RESET}
- This script does not contain any phishing links. All URLs and commands are provided for legitimate purposes related to Tempo node operations.

${GREEN}Security Best Practices${RESET}
- Always verify the integrity of the script and its source.
- Ensure you are running the script in a secure environment.
- Be cautious when entering sensitive information such as keys.

${GREEN}Disclaimer${RESET}
- The authors of this script are not responsible for any misuse or damage caused by the use of this script.
- Use this script at your own risk.

${GREEN}Contact${RESET}
- If you have any concerns or questions, please contact us at letsbuidltogether@grandvalleys.com.
"

ENDPOINTS="${GREEN}
Grand Valley Tempo public endpoints:${RESET}
- cosmos-rpc: ${BLUE}https://lightnode-rpc-tempo.grandvalleys.com${RESET}
- evm-rpc: ${BLUE}https://lightnode-json-rpc-tempo.grandvalleys.com${RESET}
- cosmos rest-api: ${BLUE}https://lightnode-api-tempo.grandvalleys.com${RESET}
- cosmos ws: ${BLUE}wss://lightnode-rpc-tempo.grandvalleys.com/websocket${RESET}
- evm ws: ${BLUE}wss://lightnode-wss-tempo.grandvalleys.com${RESET}
- peer: ${BLUE}fffb1a0dc2b6af331c65328c1ed9afad0bf107de@peer-tempo.grandvalleys.com:37656${RESET}
"

function pause() {
  echo -e "\n${YELLOW}Press Enter to continue...${RESET}"
  read -r
}

function ensure_bash_profile() {
  touch "$HOME/.bash_profile"
  if [ -f "$HOME/.bashrc" ]; then
    if grep -Eq "tempo|Tempo|\\.tempo" "$HOME/.bashrc"; then
      grep -E "tempo|Tempo|\\.tempo" "$HOME/.bashrc" >> "$HOME/.bash_profile"
      sed -i.bak '/tempo\|Tempo\|\.tempo/d' "$HOME/.bashrc"
    fi
  fi
}

function deploy_tempo_node() {
    clear
    echo -e "${RED}▓▒░ IMPORTANT DISCLAIMER AND TERMS ░▒▓${RESET}"
    echo -e "${YELLOW}1. SECURITY:${RESET}"
    echo -e "- This script ${GREEN}DOES NOT${RESET} send any data outside your server"
    echo "- All operations are performed locally"
    echo "- You are encouraged to audit the script at:"
    echo -e "  ${BLUE}https://github.com/hubofvalley/Valley-of-Tempo-Testnet/blob/main/resources/valleyofTempo.sh${RESET}"

    echo -e "\n${YELLOW}2. SYSTEM IMPACT:${RESET}"
    echo -e "${GREEN}New Service:${RESET}"
    echo -e "  • ${CYAN}tempo.service${RESET} (Consensus Client)"
    echo -e "\n${RED}Existing Service to be Replaced:${RESET}"
    echo -e "  • ${CYAN}tempo${RESET}"
    
    echo -e "\n${GREEN}Port Configuration:${RESET}"
    echo -e "Ports will be adjusted based on your input (example if you enter 38):"
    echo -e "  • ${CYAN}37657${RESET} (RPC) <-- 26657"
    echo -e "  • ${CYAN}37656${RESET} (P2P) <-- 26656"
    echo -e "  • ${CYAN}38545${RESET} (EVM-RPC) <-- 8545"
    echo -e "  • ${CYAN}38546${RESET} (WebSocket) <-- 8546"
    
    echo -e "\n${GREEN}Directories:${RESET}"
    echo -e "  • ${CYAN}$HOME/.tempo${RESET}"

    echo -e "\n${YELLOW}3. REQUIREMENTS:${RESET}"
    echo "- CPU: 8+ cores, RAM: 32+ GB, Storage: 1TB+ NVMe SSD"
    echo "- Ubuntu 22.04/24.04 recommended"

    echo -e "\n${YELLOW}4. VALIDATOR RESPONSIBILITIES:${RESET}"
    echo "- As a validator, you'll need to:"
    echo "  - Maintain good uptime (recommended 99%+)"
    echo "  - Keep your node software updated"
    echo "  - Regularly backup your keys and data"
    echo "- The network has slashing mechanisms to:"
    echo "  - Encourage validator reliability"
    echo "  - Prevent malicious behavior"

    echo -e "\n${GREEN}By continuing you agree to these terms.${RESET}"
    read -p $'\n\e[33mDo you want to proceed with installation? (yes/no): \e[0m' confirm

    if [[ "${confirm,,}" != "yes" ]]; then
        echo -e "${RED}Installation cancelled by user.${RESET}"
        menu
        return
    fi

    echo -e "\n${GREEN}Starting installation...${RESET}"
    echo -e "${YELLOW}This may take 1-5 minutes. Please don't interrupt the process.${RESET}"
    sleep 2
    
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Valley-of-Tempo-Testnet/main/resources/tempo_node_install_testnet.sh)
    menu
}

function show_logs() {
  sudo journalctl -u tempo -fn 100 -o cat
}

function show_status() {
  sudo systemctl status tempo
}

function restart_tempo() {
  sudo systemctl daemon-reload
  sudo systemctl restart tempo
  echo -e "${GREEN}tempo.service restarted.${RESET}"
}

function stop_tempo() {
  sudo systemctl stop tempo
  echo -e "${YELLOW}tempo.service stopped.${RESET}"
}

function delete_tempo_node() {
  sudo systemctl stop tempo || true
  sudo systemctl disable tempo || true
  sudo rm -f /etc/systemd/system/tempo.service
  sudo systemctl daemon-reload
  sudo rm -rf "$HOME/.tempo"
  sed -i "/TEMPO_/d" "$HOME/.bash_profile"
  sed -i "/\\.tempo/d" "$HOME/.bash_profile"
  echo -e "${RED}Tempo node deleted. Remember to clean up any keys you backed up elsewhere.${RESET}"
}

function apply_snapshot() {
  tempo download
}

function show_endpoints() {
  echo -e "$ENDPOINTS"
}

function show_guidelines() {
  echo -e "${CYAN}Guidelines on How to Use the Valley of Tempo${RESET}"
  echo -e "${GREEN}Menu tips:${RESET}"
  echo " - Enter the number/letter pair (e.g., 1a) or number then letter."
  echo " - Use 'yes/no' when prompted."
  echo -e "${GREEN}Ops tips:${RESET}"
  echo " - Check logs and status after deploy."
  echo " - Backup any keys you generate with the Tempo CLI."
  echo " - Run 'source ~/.bash_profile' after exiting to refresh env vars."
}

function menu() {
  echo -e "$LOGO"
  echo -e "$PRIVACY_SAFETY_STATEMENT"
  pause
  echo -e "$INTRO"
  echo -e "$ENDPOINTS"
  pause

  while true; do
    echo -e "${ORANGE}Valley of Tempo Testnet${RESET}"
    echo "Main Menu:"
    echo -e "${GREEN}1. Node Interactions:${RESET}"
    echo "   a. Deploy/Re-deploy Tempo Node"
    echo "   b. Apply Snapshot (tempo download)"
    echo "   c. Show Tempo Logs"
    echo "   d. Show Tempo Status"
    echo -e "${GREEN}2. Node Management:${RESET}"
    echo "   a. Restart Tempo node"
    echo "   b. Stop Tempo node"
    echo "   c. Delete Tempo Node"
    echo -e "${GREEN}3. Show Grand Valley's Endpoints${RESET}"
    echo -e "${GREEN}4. Show Guidelines${RESET}"
    echo -e "${RED}5. Exit${RESET}"

    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    if [[ $OPTION =~ ^[1-4][a-z]$ ]]; then
      MAIN_OPTION=${OPTION:0:1}
      SUB_OPTION=${OPTION:1:1}
    else
      MAIN_OPTION=$OPTION
      if [[ $MAIN_OPTION =~ ^[1-2]$ ]]; then
        read -p "Choose a sub-option: " SUB_OPTION
      fi
    fi

    case $MAIN_OPTION in
      1)
        case $SUB_OPTION in
          a) deploy_tempo_node ;;
          b) apply_snapshot ;;
          c) show_logs ;;
          d) show_status ;;
          *) echo "Invalid sub-option. Please try again." ;;
        esac
        pause
        ;;
      2)
        case $SUB_OPTION in
          a) restart_tempo ;;
          b) stop_tempo ;;
          c) delete_tempo_node ;;
          *) echo "Invalid sub-option. Please try again." ;;
        esac
        pause
        ;;
      3) show_endpoints; pause ;;
      4) show_guidelines; pause ;;
      5) exit 0 ;;
      *) echo "Invalid option. Please try again."; pause ;;
    esac
  done
}

menu
