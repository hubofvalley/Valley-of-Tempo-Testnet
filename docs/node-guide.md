# Tempo Node Guide

Deploy and manage a Tempo node on Moderato testnet.

## System Requirements

| Category | Requirements |
|----------|--------------|
| CPU | 8+ cores |
| RAM | 32+ GB |
| Storage | 500+ GB NVMe SSD |
| Bandwidth | 1 GBit/s |
| OS | Ubuntu 22.04/24.04 (recommended) |

## Installation

1. Launch Valley of Tempo:
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Valley-of-Tempo-Testnet/main/resources/valleyofTempo.sh)
   ```
2. Select **"Node Interactions"** → **"Deploy/Re-deploy Tempo Node"**
3. Follow the interactive prompts

### What Gets Installed

| Component | Details |
|-----------|---------|
| **tempo** | Tempo binary (v1.0.0-rc.1) |
| **tempo.service** | Systemd service |
| **Data directory** | `$HOME/.tempo` |

## Upgrading

1. Launch Valley of Tempo
2. Select **"Node Interactions"** → **"Upgrade Tempo binary"**

## Service Management

| Action | Menu Path |
|--------|-----------|
| Show status | **"Node Interactions"** → **"Show Tempo Status"** |
| Show logs | **"Node Interactions"** → **"Show Tempo Logs"** |
| Restart | **"Node Management"** → **"Restart Tempo node"** |
| Stop | **"Node Management"** → **"Stop Tempo node"** |
| Delete | **"Node Management"** → **"Delete Tempo Node"** |

## Adding Peers

1. Launch Valley of Tempo
2. Select **"Node Interactions"** → **"Add Trusted Peer"**
3. Choose:
   - **g** - Add Grand Valley's peer
   - **m** - Enter manually

## Network Migration

If migrating from Andantino to Moderato testnet:

1. Launch Valley of Tempo
2. Select **"Node Interactions"** → **"Migrate from Andantino to Moderato"**

This will:
- Stop tempo.service
- Delete old database
- Update binary to v1.0.0-rc.1
- Replace service file
- Optionally apply snapshot
- Start the node

## Install Tempo App Only

Install only the Tempo CLI and cast for transactions:

1. Launch Valley of Tempo
2. Select **"Install the Tempo App only"**

## Related Documentation

- [Snapshots Guide](snapshots.md)
