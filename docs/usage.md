# Valley of Tempo Testnet - Usage Guide

How to run the tool, how to navigate it, and what every menu option does.

## Running the tool

```bash
bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Valley-of-Tempo-Testnet/main/resources/valleyofTempo.sh)
```

Or from a local clone:

```bash
bash resources/valleyofTempo.sh
```

Run it as the user that owns `$HOME/.tempo`. The script stores Tempo environment variables in `~/.bash_profile`.

## Navigation

- Choose an option by typing number + letter together, for example `1f`, or type the number first and then the letter when prompted.
- Node install, upgrade, snapshot, migration, and delete actions can change local state.
- After exiting, run `source ~/.bash_profile` so exported variables apply to the current shell.

## Menu options explained

| Option | What it does | When to use | Destructive / risk |
|---|---|---|---|
| 1a. Deploy/Re-deploy Tempo Node | Runs the Tempo testnet installer. | First setup or clean redeploy. | Yes - may replace service/data. Backup first. |
| 1b. Upgrade Tempo binary | Downloads and applies official Tempo binary update. | Upstream binary release. | Medium - binary/service change. |
| 1c. Apply Snapshot | Downloads and applies official Tempo snapshot. | Speed up sync or recover data. | Yes - can replace node data. |
| 1d. Add Trusted Peer | Adds a trusted enode peer. | Connectivity repair. | Low - config change. |
| 1e. Migrate from Andantino to Moderato | Runs network migration flow. | Only if still on old Andantino state. | High - may overwrite data. |
| 1f. Show Tempo Status | Compares local JSON-RPC block height to Tempo public RPC. | Health/sync check. | No. |
| 1g. Show Tempo Logs | Tails `tempo` service logs. | Debugging. | No. |
| 2a. Restart Tempo node | Restarts Tempo service. | After config/binary changes. | Low - downtime. |
| 2b. Stop Tempo node | Stops Tempo service. | Maintenance. | Medium - node offline. |
| 2c. Delete Tempo Node | Removes Tempo service/data. | Decommission or clean reinstall. | Yes - destructive. Backup first. |
| 3. Install the Tempo App | Installs Tempo app/binary only, without running a node. | Need CLI/app access only. | Medium - binary install. |
| 4. Show Grand Valley's Endpoints | Prints endpoints and links. | Reference. | No. |
| 5. Show Guidelines | Shows in-tool guidance. | First-time use. | No. |
| 6. Exit | Leaves the script. | Done. | No. |

## Recommended first-time flow

1. Run `1a`, then monitor with `1f` and `1g`.
2. Add trusted peer with `1d` only if connectivity is weak.
3. Use `1b` when an official Tempo update is announced.
4. Use `1c`, `1e`, or `2c` only after backup and manual confirmation.

## Safety notes

- Snapshot, migration, and delete operations can overwrite or remove local data.
- Tempo testnet state can change; confirm upstream guide before a migration.
- Test risky flows on a disposable VPS first when possible.
