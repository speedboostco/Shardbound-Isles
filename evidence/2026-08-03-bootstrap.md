# Bootstrap Evidence — 2026-08-03

Environment: Windows, Godot 4.7.1 stable. `godot` and `make` were not on PATH; commands used the repository PowerShell wrapper and discovered the local editor executable.

## Automated validation

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 import` — exit 0; project scan and editor load completed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 test-unit` — exit 0; 5 assertions, 0 failures.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 test-integration` — exit 0; 6 assertions, 0 failures.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 test-simulation` — exit 0; 5 assertions, 0 failures.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 validate` — exit 0; import completed and all 16 assertions passed.
- `git diff --check` — no whitespace errors. Git emitted only line-ending and inaccessible global-ignore warnings.

Godot emitted `Failed to read the root certificate store` in the restricted environment. It did not change exit status or offline project/test behavior.

## Fixed-seed scenario

Seed `424242` scripted two tree hits, wood collection, three enemy hits, and equipment collection. Metrics:

```json
{"enemies_defeated":1,"item":{"archetype":"ranged","id":"starter_ranged_424242","name":"Tideglass Bow","power":5,"rarity":"uncommon","seed":424242},"items_collected":1,"seed":424242,"wood":3}
```

## Blocked or incomplete evidence

- `scripts/dev.ps1 export-windows` — exit 1: Godot 4.7.1 Windows templates absent.
- `scripts/dev.ps1 export-linux` — exit 1: Godot 4.7.1 Linux templates absent.
- A 1280x800 GUI launch was attempted, but the environment wrapper did not return cleanly and it was terminated. No screenshot, controller hardware check, text-readability review, clipping review, or gameplay feel assessment is claimed.
- CI is configured to install templates, run all tests, and export Linux, but the workflow has not been executed in this local uncommitted workspace.

## Equipment milestone evidence

- `scripts/dev.ps1 validate` — exit 0; import completed and all 36 assertions passed.
- Unit coverage verifies authoritative collect, compare, equip, attack damage, equipped-item protection, unequip, and deterministic salvage rules.
- Integration coverage verifies modal focus, HUD updates, increased damage dealt, salvage protection and reward, and controller cancel behavior.
- `tests/visual/capture_equipment_panel.gd` — exit 0; captured `equipment-panel-1280x800.png` at 1280x800 using seed `424242`.
- Visual inspection verified readable text, visible Equip focus, no clipping or overlap, no missing assets, safe anchors, and opaque modal layering. The first capture exposed excessive transparency; the panel style was corrected and recaptured.
- Physical controller hardware was not exercised; controller behavior is automated at the InputMap/focus level.
