# M1 First Playable Loop Evidence

## Outcome by requirement

- PLY-001: movement preserves analog strength, caps diagonal speed, uses physics delta, and is covered by pure and scene-input tests.
- PLY-002: the camera follows with smoothing inside arena limits. Deterministic shake is independently switchable and disabled by default. The player and world remain readable at 1280x800.
- PLY-003: one nearest-target selector, one `A / E` action, stable tie-breaking, and one contextual prompt serve workbenches and unlocked rifts without pointer input.
- RES-001 / RES-002: tree and stone share a typed definition-driven runtime node with hit stages. Physical pickups merge by resource, attract magnetically, and collect automatically; 100 wood drops coalesce into one stack.
- INV-001: `ResourceInventory` owns non-negative quantities and atomic add/remove/set operations, and emits event-driven HUD updates.
- COM-001 / COM-002: player and enemies compose the shared `HealthComponent`. Damage, healing, one-shot death, player invulnerability, facing, single-target strikes, real weapon cooldown, and hit feedback are tested.
- ENM-001: the green Slime has explicit Idle, Chase, Attack, and Dead states, collision recovery, a three-hit unarmed health target, one death emission, no post-death movement, and a configured reward policy.
- ITEM-001 / LOOT-001: authored `WeaponDefinition` and runtime `WeaponInstance` are separate. Canonical state contains item ID, base type, damage, attack speed, rarity, and seed; fixed seed/context produces a stable round trip. The first Slime drops one world pickup and the second proves loot is optional.
- EQUIP-001: one compatible weapon equips from authoritative inventory, incompatible types are rejected, the old weapon remains owned, and both damage and attack speed affect play.
- UI-001: health, equipped weapon, wood, stone, and the interaction prompt are event-driven and readable without center obstruction or mouse hover.
- SIM-001: the scripted scenario moves from spawn to tree, stone, first Slime, weapon pickup/equip, and second Slime, then repeats the exact sequence for deterministic equality.

## Validation

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/dev.ps1 validate` with `GODOT_BIN` set to Godot 4.7.1 - exit 0; import succeeded, static checks 18/18, automated assertions 348/348, failures 0.
- Unit layer - 163 assertions, 0 failures.
- Integration layer - 168 assertions, 0 failures.
- Simulation layer - 17 assertions, 0 failures.
- JUnit: `build/test-results/all.xml` was written by the successful full run.
- `M1_PICKUP_METRICS {"drops":100,"elapsed_usec":260}` - one merged physical stack preserving all 100 units, below the 500 ms contract.
- `git diff --check` - no whitespace errors during final review.

Godot emitted the host certificate-store warning after otherwise successful processes. It did not change the exit code or test results.

## Gameplay reproduction

```text
SMOKE_METRICS {"enemies_defeated":2,"equipped_attack_speed":1.35,"equipped_damage":6,"equipped_hits":1,"equipped_id":"starter_ranged_424242","items_collected":1,"movement_steps":308,"seed":424242,"stone":2,"unarmed_damage":1,"unarmed_hits":3,"wood":3}
TEST_RESULT suite=all assertions=348 failures=0
```

Visual artifact: [M1 first playable at 1280x800](m1-first-playable-1280x800.png).

Manual inspection confirms readable health/resources/weapon stats, a visible green Slime, distinct tree and stone, the equipped Tideglass Bow, a bottom-safe `A / E USE WORKBENCH` prompt, no central HUD obstruction, no clipped text, and no missing assets.

## External validation limitations

- GNU Make is not installed on this Windows host, so the PowerShell implementation called by each Make target was exercised directly.
- Local Windows and Linux exports both exit 1 with explicit missing-template errors because Godot 4.7.1 export templates are absent. The repository presets and CI export jobs are present, but no local binary was produced in this run.
- A physical ten-minute controller playthrough and Windows-build launch under Steam Deck Proton require the corresponding controller, export templates, and Steam Deck/Proton host; these hardware gates were not claimed as passed.
