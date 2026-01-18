# Snapshots Guide

Apply snapshots for faster node synchronization on Moderato testnet.

## Applying Snapshot

1. Launch Valley of Tempo:
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Valley-of-Tempo-Testnet/main/resources/valleyofTempo.sh)
   ```
2. Select **"Node Interactions"** → **"Apply Snapshot"**
3. Confirm to proceed

The script will:
- Stop tempo.service
- Download official Tempo snapshot
- Extract to `$HOME/.tempo/data`
- Restart tempo.service

## Important Notes

- Snapshots may overwrite existing data
- Ensure sufficient disk space before applying
- Monitor logs after applying to verify sync

## Related Documentation

- [Node Guide](node-guide.md)
