# Changelog

## Unreleased

- Reorganize live Godot resources under `game/`, developer tooling under `tools/`, and tracked build-output guidance under `build/` with documented layer ownership.
- Bootstrap the Godot project, documentation system, stable developer commands, CI, tests, and debug export presets.
- Add the first deterministic gather–fight–loot playable milestone.
- Add controller-first equipment comparison, equipping, attack-power changes, equipped-item protection, and deterministic salvaging.
- Add a controller-first workbench and Reinforced Heart recipe consuming gathered wood and salvage scrap for a permanent health increase.
- Clamp the camera to the arena after visual evidence exposed out-of-world rendering near the workbench.
- Add the Tidecatcher: controller-built deterministic wood automation with capped storage and automatic nearby collection.
- Add schema-versioned single-slot local save/load with validated canonical restoration and controller-focused system UI.
- Add the deterministic Verdant Crucible island shard, physical eastern installation slot, risk/reward modifiers, and schema-1-to-2 save migration.
- Add the Tide Slinger ranged archetype, telegraphed projectiles, and elite Stormcaller three-shot behavior with deterministic loot.
- Add the two-phase Abyssal Warden boss encounter and deterministic legendary Riftwake Core reward.
- Add the boss-unlocked repeatable three-wave rift, safe failure/retreat flow, and capped run-indexed rewards.
- Make Riftwake Core behavior-changing with a deterministic radial Riftwake Pulse, in-panel affix explanation, persistence-derived activation, and boss/rift interaction coverage.
- Harden the test runner so script load, compile, and instantiation failures cannot silently pass as zero-assertion suites.
- Expand world loot to Verdant Crucible, Emberglass Reach, and Tempest Loom with distinct gathering, combat, automation, projectile-risk, controller-selection, and physical-biome behavior.
- Add per-test assertion-count contracts so interrupted runtime tests cannot silently report a partial pass.
- Add controller equipment-inventory browsing with selected-index equip/salvage actions, clamped selection, focus recovery, and accurate island-adjusted attack display.
- Share rarity salvage values between domain actions and comparison UI after visual review exposed a legendary 10-versus-1 mismatch.
- Add a three-hit cracked stone outcrop, distinct stone pickup/HUD inventory, and controller-browsed Runed Whetstone upgrade granting permanent +1 base attack.
- Advance saves to schema 3 with explicit schema-1/schema-2 stone-era migrations and derived Whetstone restoration.
- Stop test execution immediately after incomplete assertion contracts to prevent leaked scenes from contaminating later tests.
