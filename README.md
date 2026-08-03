
# Shardbound Isles

An offline, controller-first 2D action RPG where the world itself is loot. The current playable milestone includes deterministic equipment plus previewable island shards, three physical archipelago slots, compositional island modifiers, saved runtime island progress, and adjacency tradeoffs.

## Requirements

- Godot 4.x stable (CI validates against 4.4.1).
- GNU Make for the documented command aliases, or PowerShell on Windows for direct script use.

Set `GODOT_BIN` if Godot is not on `PATH`.

## Start

```text
make help
make setup
make validate
make run
```

On Windows without Make, use `powershell -NoProfile -ExecutionPolicy Bypass -File tools/dev.ps1 help` and replace `help` with any listed command.

Move with WASD, arrow keys, left stick, or D-pad. Attack with Space, Enter, or the controller west face button (X / Square); interact with E or the south face button. Open island shards with J/right shoulder, inspect risk and rewards, choose a slot, and install. Forest + Swamp previews Rare Spores; Forest Moonleaf crafts the Herbal Compass at the workbench.

Read [AGENTS.md](AGENTS.md), then the active plan under `docs/exec-plans/active/`, before changing code.
