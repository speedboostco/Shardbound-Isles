# Tasks 16-30 conformance evidence

Date: 2026-08-09  
Source: `Shardbound_Isles_Tasks_16-30.docx`  
Repository result: complete  
External product gate: pending real Steam Deck playtest

## Outcome

The pre-existing M1/M2 implementation was audited against the more detailed Tasks 16-30 document and repaired where its executable contracts were weaker. This pass preserves M1-M4 saves and gameplay while adding canonical item identity/validation, seeded optional drop decisions, a physical bow projectile, complete affix eligibility diagnostics, evented equipment mutations, pure tooltip/comparison presentation, and transactional confirmed salvage.

The document mandates a real Steam Deck controller-only playtest after Task 20. This Windows host reports zero matching present controllers and no Steam command, so that hardware judgment is not claimed. Tasks 21-30 already existed before this request; they were audited and hardened rather than newly expanded past an unperformed gate.

## Acceptance mapping

| Task | Result | Evidence |
| --- | --- | --- |
| 16 / ITEM-001 | Pass | `WeaponDefinition.validation_errors`, `WeaponInstance.validation_errors`, canonical `instance_id` plus `item_id`/`id` compatibility aliases, fixed-seed/context identity, round trip and invalid-range unit tests. |
| 17 / LOOT-001 | Pass | `LootDropDecision` uses a derived explicit stream; fixed M1 seed gives first-Slime drop and second-Slime no-drop. Rejected duplicate pickup remains in the world and is retry-throttled. |
| 18 / EQUIP-001 | Pass | Owned/compatible equip, idempotency, replacement preservation, damage/cadence application, `equipment_changed` event, controller action and improved M1 time-to-kill. |
| 19 / UI-001 | Pass | Event-driven health/resources/equipment/prompt HUD. Normal, damaged, pickup and equipped 1280x800 captures are listed below. |
| 20 / SIM-001 | Pass (automated) | Fixed route repeats spawn/move/gather/kill/drop/pickup/equip/second kill and writes machine-readable/JUnit results. Real Steam Deck enjoyment gate remains external. |
| 21 / WPN-001 | Pass | Shared target rules drive short sword, tracked bow projectile and wand splash. Integration verifies delayed bow impact and cleanup on weapon change. |
| 22 / ITEM-002 | Pass | Five validated serializable tiers, configurable weights/affix bounds, zero/single-tier boundaries, deterministic 50k distribution and textual rarity UI. |
| 23 / AFF-001 | Pass | Sixteen normalized definitions expose stable ID/display key/category/range/weight/type/tag/level/tier/conflict data; invalid IDs, ranges, weights, types and tags fail validation. |
| 24 / AFF-002 | Pass | Pure stable diagnostics cover allowed/required/excluded tags, level/tier, duplicates and conflicts; order independence and no-candidate behavior are safe. |
| 25 / LOOT-002 | Pass | Full seeded pipeline validates exact rarity count, eligibility, conflicts and roll ranges; 10,000 generated items pass and JSON reconstruct. |
| 26 / EQUIP-002 | Pass | Six typed slots, duplicate ownership rejection, non-mutating invalid operations, change events and schema-6 reconstruction. |
| 27 / STAT-001 | Pass | Documented additive-before-multiplicative recomposition, source removal/idempotency and critical/attack-speed clamps. Seeded 500-operation simulation returns exactly to baseline. |
| 28 / UI-002 | Pass | Pure `ItemTooltipPresenter`, textual rarity, consistent values, fallbacks, bounded scrolling, controller modal and short/long captures. |
| 29 / UI-003 | Pass | Same-slot/empty-slot resolution, candidate/equipped identities and affixes, signed gameplay deltas, behavior sections, no item score, explicit equip/keep/close. |
| 30 / SALV-001 | Pass | Stable-ID plan/commit transaction, deterministic rarity/level reward, equipped/favorite protection, stale/duplicate rejection, events, and two-press controller warning. |

## Automated validation

Stable Windows-host command (GNU Make is unavailable):

```text
$env:GODOT_BIN='C:\Users\vserg\Downloads\Godot_v4.7.1-stable_win64.exe'
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\dev.ps1 validate
```

Final result: import exit 0; `STATIC_RESULT checks=25 failures=0`; `TEST_RESULT suite=all assertions=732 failures=0`; JUnit written to `build/test-results/all.xml`.

Layer results exercised during implementation:

- Unit: 397 assertions, 0 failures.
- Integration: 280 assertions, 0 failures.
- Simulation: 55 assertions, 0 failures.

Deterministic metrics:

```json
TASKS_16_30_METRICS {"baseline_restored":true,"equipped_after_clear":0,"expected_scrap":315,"initial_items":48,"salvaged_items":48,"scrap":315,"seed":30100,"unique_ownership":true}
SMOKE_METRICS {"enemies_defeated":2,"equipped_attack_speed":1.35,"equipped_damage":6,"equipped_hits":1,"equipped_id":"starter_ranged_424242","items_collected":1,"movement_steps":308,"seed":424242,"stone":2,"unarmed_damage":1,"unarmed_hits":3,"wood":3}
M2_LOOT_METRICS {"items":10000}
```

## Visual/controller evidence

The reproducible capture script is `game/tests/visual/capture_tasks_16_30.gd`. Every artifact is exactly 1280x800:

- [M1 normal](tasks-16-30-m1-normal-1280x800.png)
- [M1 damaged](tasks-16-30-m1-damaged-1280x800.png)
- [M1 visible pickup](tasks-16-30-m1-pickup-1280x800.png)
- [M1 equipped](tasks-16-30-m1-equipped-1280x800.png)
- [Short tooltip and empty slot](tasks-16-30-tooltip-short-empty-slot-1280x800.png)
- [Long Legendary comparison](tasks-16-30-tooltip-long-comparison-1280x800.png)
- [Salvage confirmation](tasks-16-30-salvage-confirmation-1280x800.png)

Manual artifact review found readable HUD values, a visible world drop, clear candidate/equipped labels, textual rarities, wrapped long content with a visible scroll affordance, all buttons inside the viewport, and focused `CONFIRM +15` destructive action. No missing assets, center-blocking HUD, or clipped panel bounds were observed.

## Builds

- `export-windows`: exit 0; EXE 102,982,144 bytes, PCK 484,272 bytes.
- `export-linux`: exit 0; binary 73,675,128 bytes, PCK 484,272 bytes, launcher 136 bytes.
- Exported Windows executable isolated headless smoke: exit 0.
- Windows PCK SHA-256: `FB5B00D12C4915FA2563DDD904AEEB588211232BB4B40823CBF6AF307079A924`.
- Linux PCK SHA-256: `FB5B00D12C4915FA2563DDD904AEEB588211232BB4B40823CBF6AF307079A924`.

## Known limitations

- The mandatory real Steam Deck controller-only playtest and qualitative “feels genuinely stronger/fun” decision require human hardware; automated timing and Windows visual evidence cannot replace it.
- Controller focus/navigation is automated through Godot input contracts, but no physical controller is connected to this host.
- Godot emits the host root-certificate-store warning after successful offline commands; it does not change exit codes, imports, tests, exports, or local play.
