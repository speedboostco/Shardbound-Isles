# INF-002 Repository Structure Evidence

## Structure

- `game/core/`: 24 rule and UID files.
- `game/features/`: 28 gameplay and UID files.
- `game/ui/`: HUD scene, script, and UID.
- `game/content/`: the active `world.tscn` composition root.
- `game/tests/`: 72 runner, automated-test, visual-test, and UID files.
- `tools/`: the stable `dev.ps1` command implementation.
- `build/`: tracked responsibility README and Godot ignore marker; generated platform output remains ignored.

The obsolete top-level `src/`, `scripts/`, and `tests/` paths are absent. A live-path search found no `res://src/`, `res://tests/`, or old developer-script references outside historical evidence and source prompts.

## Commands

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/dev.ps1 import` — exit 0; Godot 4.7.1 scanned the moved tree and registered 63 scripts without project parse or resource errors.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/dev.ps1 validate` — exit 0; 228 assertions, 0 failures.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/dev.ps1 help` — exit 0; the moved command interface listed all stable commands.
- `git diff --check` — exit 0.

## Reproduction evidence

The full validation exercised the fixed-seed first-playable simulation after the move:

```text
SMOKE_METRICS {"enemies_defeated":1,"item":{"archetype":"ranged","id":"starter_ranged_424242","name":"Tideglass Bow","power":5,"rarity":"uncommon","seed":424242},"items_collected":1,"seed":424242,"wood":3}
RIFT_METRICS {"first_reward_seed":8801,"runs_started":2,"second_run_status":"failed","waves_cleared":3}
TEST_RESULT suite=all assertions=228 failures=0
```

Both Godot invocations also emitted the host-only message `Failed to read the root certificate store`; it did not affect exit status, import, or offline tests.

GNU Make is not installed on this Windows host, so the `make help` alias was not executable here. The PowerShell implementation that the Makefile delegates to was exercised directly.
