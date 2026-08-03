# Changelog

## Unreleased

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
