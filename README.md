
# Shardbound Isles

An offline, controller-first 2D action RPG where the world itself is loot. This repository currently contains the bootstrap and first playable gather–fight–loot milestone.

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

On Windows without Make, use `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 help` and replace `help` with any listed command.

Move with WASD, arrow keys, left stick, or D-pad. Attack with Space, Enter, or the controller south face button. Break the tree, collect its wood automatically, defeat the red wisp, and collect its deterministic equipment drop.

Read [AGENTS.md](AGENTS.md), then the active plan under `docs/exec-plans/active/`, before changing code.
