# M4 — Crafting, Base, and Automation Evidence

Date: 2026-08-09  
Godot: 4.7.1 stable  
Reference viewport: 1280×800

## Outcome

M4 gate is implemented. The playable route manually acquires resources, uses five data-driven workbench recipes, places and rotates buildings on stable sockets, routes ordinary drops through collector/shared storage/lumber mill, produces and collects planks, safely upgrades an equipped item, and persists/resumes the complete committed state.

## Automated evidence

The repository command used the documented PowerShell equivalent because GNU Make is not installed on this Windows host:

```powershell
$env:GODOT_BIN='C:\Users\vserg\Downloads\Godot_v4.7.1-stable_win64.exe'
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\dev.ps1 validate
```

Result:

- Godot project import: exit 0.
- Static validation: `STATIC_RESULT checks=24 failures=0`.
- All tests: `TEST_RESULT suite=all assertions=680 failures=0`.
- JUnit: `build/test-results/all.xml`.
- Unit layer in the final suite includes recipe/ID validation, atomic output blocking, placement, storage, mill, collector, offline bounds, upgrades, and schema migration.
- Integration layer includes 267 assertions; its M4 route uses actual HUD button signals for wood deposit/plank collection, controller placement, confirmation, save/load, and protected upgrades.
- Simulation layer includes 49 assertions and printed:

```text
M4_METRICS {"buildings":2,"collector_batch":8,"manual_wood_spent":10,"planks_produced":3,"preview_absent":true,"round_trip_valid":true,"storage_total":10,"upgrade_level":1,"upgrade_power_gain":1}
```

The M4 route is executed twice and requires exact metric equality.

## Build evidence

Both documented export commands completed with exit 0:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\dev.ps1 export-windows
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\dev.ps1 export-linux
```

- Windows: `build/windows/ShardboundIsles.exe` (102,982,144 bytes) and `.pck` (450,804 bytes).
- Linux: `build/linux/ShardboundIsles.x86_64` (73,675,128 bytes), `.pck` (450,804 bytes), and launcher script.
- Exported Windows binary smoke: isolated writable `LOCALAPPDATA`/`APPDATA`, `--headless --quit-after 180`, exit 0.

A first Windows smoke attempt without isolated user directories could not open `user://logs` in the sandbox and entered Godot's crash handler. It is not counted as passing evidence; the documented isolated rerun above is the valid result.

## Gameplay and visual evidence

- `m4-placement-invalid-1280x800.png`: red invalid lumber-mill preview on the player's socket, disabled Place, visible socket/rotation/cancel controls, controller focus present.
- `m4-base-flow-1280x800.png`: distinct physical mill and collector plus readable `collector → storage → mill` quantities, progress, and safe-output state.
- `m4-upgrade-confirm-1280x800.png`: exact `+0 → +1`, `POWER 5 → 6`, `COST 2 SCRAP`, second-confirmation wording, focused confirmation action, and transfer controls without clipping.

Manual image inspection at original resolution found no missing assets, modal clipping, text truncation, lost focus indicator, or overlap in the feature UI. HUD is explicitly rendered above world projections.

## Limits checked

- Collector: 180-pixel radius, 8 targets per batch, 12-unit local capacity; rare, encounter, and player-owned rewards excluded.
- Shared storage: 24 total units with accepted/remainder overflow handling.
- Mill: 12 wood input, 8 plank output, 2 wood → 1 plank every 3 seconds; full output consumes nothing.
- Offline catch-up: negative time becomes zero, maximum four hours, then constrained by all inventory capacities.
- Upgrades: +10 cap, +5 maximum added power, Moonleaf from +7, no failure/destruction/affix loss.

## Known limitations

- Controller behavior is validated through InputMap signals, focus ownership, button flows, and 1280×800 captures; no physical controller or Steam Deck was available for feel testing.
- Linux was cross-exported on Windows but not executed on a Linux host.
- Building visuals are authored Godot primitives suitable for system validation, not final art.

