# Bootstrap and First Playable

Status: active

## Goal

Establish the repository contract and deliver one deterministic, controller-playable path: move, break one tree, collect wood, attack one enemy, and collect one equipment drop.

## Assumptions

- Simple vector art drawn by Godot is acceptable bootstrap art.
- Godot 4.7.1 is the available stable 4.x editor; the project stays compatible with 4.x APIs.
- A dependency-free Godot test runner is preferable until a maintained third-party test plugin can be reviewed and pinned.
- Phase 1 equipment is collected and shown but not yet equippable; equipping belongs to the next milestone.

## Acceptance criteria

- `project.godot` imports without script errors.
- WASD, arrows, left stick, and D-pad move the player; Space/Enter and controller face button attack.
- A following camera frames a 1280x800 play area.
- A tree takes deterministic damage, drops wood, and nearby wood is automatically collected.
- One enemy pursues and damages the player, can be killed, and drops the same deterministic item for seed `424242`.
- The HUD presents health, wood, equipment pickup, controls, and objective.
- Unit, integration, and fixed-seed smoke tests pass headlessly.
- Windows and Linux debug export presets exist; exports are attempted and results recorded.

## Tests defined before production code

- Unit: seeded equipment generation repeats and produces the expected valid weapon data.
- Integration: resource damage/drop/pickup and enemy death/drop signals complete the path.
- Simulation: fixed-seed scripted scenario reaches wood `>= 3`, enemy defeated, and one equipment item collected.
- Import: headless editor import exits successfully.

## Expected files and systems

- Godot configuration and export presets.
- `game/core`: deterministic equipment generation.
- `game/features`: player, tree, pickup, enemy, item pickup, world orchestration.
- `game/ui`: minimal HUD.
- `game/content`: composed first-playable world scene.
- `game/tests`: dependency-free runners for automated and visual layers.
- `tools` and `Makefile`: stable developer commands.
- Product/design/engineering documentation and CI.

## Milestones

1. Repository knowledge, project shell, command interface, CI, and boot scene.
2. Pure deterministic item generation plus unit test.
3. Playable gather/combat/drop path plus integration tests.
4. Fixed-seed smoke scenario, validation, export attempts, evidence, and documentation sync.
5. Backlog: equipment comparison/equip/salvage, second resources/enemies, crafting, automation, shards, rift, saves, polish.

## Milestone 2: equipment decisions

Goal: turn the collected deterministic weapon into a controller-first build decision without adding broader loot content.

Acceptance criteria:

- Collected equipment is stored in authoritative gameplay state.
- The equipment panel displays the selected item, equipped item, power comparison, and salvage value.
- The panel opens and all actions work with keyboard or controller; no pointer is required.
- Equipping changes the player's displayed attack damage and damage dealt.
- Salvaging removes the item and grants deterministic scrap; equipped items cannot be salvaged accidentally.
- Pure inventory rules and scene/UI interactions have deterministic automated coverage.

Tests defined before production changes:

- Unit: collect, compare, equip, damage calculation, salvage reward, and equipped-item protection.
- Integration: collecting the fixed drop updates the panel; equip updates player damage/HUD; salvage updates scrap and removes the item.
- Controller UI: opening the panel assigns focus to a valid action and cancel closes it.

Expected changes: equipment domain state, player attack damage, HUD equipment panel, world action wiring, input actions, tests, and synchronized loot/UI/controls documentation.

Risk and rollback: controller focus can become trapped or gameplay can continue behind the modal. Keep authoritative actions in the world, pause player input while the panel is open, and make the panel a removable HUD composition.

## Risks and rollback

- Export templates may be absent. Preserve verified project/test work and report exports as blocked.
- Headless execution cannot prove rendered readability. Keep visual evidence separate from logic evidence.
- Godot API differences may surface. Prefer stable 4.x APIs and correct failures rather than version-locking gameplay.
- Rollback is file-local: bootstrap features are composed scenes and scripts with no save compatibility yet.

## Discoveries and evidence

- 2026-08-03: repository contained no Godot project or tooling.
- 2026-08-03: `godot` and `make` were absent from PATH; `C:\Users\vserg\Downloads\Godot_v4.7.1-stable_win64.exe` is available.
- 2026-08-03: headless import passed with Godot 4.7.1 after redirecting editor caches into ignored workspace storage. Godot logs a sandbox-specific root certificate-store warning.
- 2026-08-03: unit tests passed 5/5, integration tests passed 6/6, simulation tests passed 5/5; full validation passed 16/16.
- 2026-08-03: seed `424242` produced `starter_ranged_424242`, Tideglass Bow, power 5. The smoke scenario gathered 3 wood, defeated 1 enemy, and collected 1 item.
- 2026-08-03: Windows and Linux export attempts failed because Godot 4.7.1 export templates are not installed. Presets resolved correctly.
- 2026-08-03: a 1280x800 GUI launch was attempted but did not return cleanly through the execution wrapper and was terminated; no screenshot or manual controller/readability evidence was obtained.

The plan remains active because export and visual/controller acceptance criteria do not yet have local evidence.

### Milestone 2 evidence — 2026-08-03

- Equipment inventory unit tests pass: collect, comparison, equip, attack damage, protection, unequip, and salvage.
- Integration tests pass: pickup refresh, modal opening, valid action focus, displayed and dealt damage, salvage protection/reward, and close behavior.
- Full validation passes with 36 assertions and 0 failures.
- Reproducible GUI evidence captured at exactly 1280x800 in `evidence/equipment-panel-1280x800.png` using seed `424242`.
- Visual review found and corrected excessive modal transparency. Final review confirms readable text, visible focus, no clipping/overlap, no missing assets, correct anchors, and modal-over-gameplay layering.
- Controller behavior is covered through InputMap actions and focus assertions, but no physical controller hardware was available for a manual feel check.

## Milestone 3: first workbench recipe

Goal: convert the complete gather–fight–salvage output into one visible character upgrade through a controller-first workbench.

Assumptions:

- The first recipe costs exactly 3 wood and 2 scrap so it closes the currently playable loop.
- A Reinforced Heart adding 2 maximum health is a meaningful initial craft without introducing a broader item taxonomy.
- The recipe is unique per run; repeated crafting must be rejected without consuming resources.

Acceptance criteria:

- A visible workbench can be approached and opened without a pointer.
- The modal displays recipe effect, costs, affordability, and explicit success/failure feedback.
- Crafting consumes authoritative world resources only after validation.
- Reinforced Heart raises maximum and current health from 10 to 12 and cannot be crafted twice.
- Opening the modal assigns valid controller focus and suspends combat movement; cancel closes it.
- Unit, integration, and 1280x800 visual evidence cover the new flow.

Tests defined before production changes:

- Unit: exact affordability, insufficient-resource rejection, successful result, and already-crafted rejection.
- Integration: proximity gate, modal focus, authoritative deductions, health increase, duplicate rejection, feedback, and close behavior.
- Visual: fixed-state 1280x800 workbench modal showing affordable recipe and focused craft action.

Expected changes: pure crafting rule, workbench scene, world interaction/action wiring, HUD crafting modal, tests, InputMap, docs, and evidence.

Risk and rollback: modal duplication can create conflicting focus or leave gameplay frozen. Only one modal may be visible; close signals restore gameplay through the world composition root.

### Milestone 3 evidence — 2026-08-03

- Crafting unit tests pass: 8 assertions covering exact affordability, both insufficient inputs, successful result, exact deductions/effect, duplicate rejection, and failure reasons.
- Workbench integration tests pass: 12 assertions covering proximity, modal focus, authoritative deductions, health increase to 12/12, duplicate protection, feedback, and gameplay restoration.
- Reproducible GUI evidence captured at 1280x800 in `evidence/workbench-panel-1280x800.png` with the affordable recipe and Craft action focused.
- The first visual capture exposed out-of-world rendering when the camera followed the player north. Camera limits were added and the evidence was recaptured.
- Final visual review confirms readable text, no clipping/overlap, visible focus, correct opaque layering, visible workbench identity, and no missing assets.

## Milestone 4: Tidecatcher automation

Goal: reward mastery of manual tree gathering with one compact production building that creates wood without replacing exploration or combat.

Assumptions:

- Crafting the Reinforced Heart unlocks one free Tidecatcher construction choice; this avoids requiring a tree respawn solely to pay another cost.
- The Tidecatcher produces 1 wood every 2 seconds and stores at most 6.
- Stored wood transfers automatically when the player enters collection range, removing a repeated button chore.
- Production is run-local until the save milestone exists.

Acceptance criteria:

- The workbench offers controller-focused construction only after the Reinforced Heart is crafted.
- Construction activates a visible building once and rejects duplicates.
- Seed-independent production timing is deterministic, chunk-size independent, and capped at 6.
- Approaching the building transfers all stored wood to authoritative inventory and gives visible feedback.
- Tests cover timing, cap, collection, unlock, construction, duplicate protection, and world transfer.
- A 1280x800 artifact proves readable construction or production state.

Tests defined before production changes:

- Unit: sub-interval production, exact interval, chunk-size independence, storage cap, and collection reset.
- Integration: locked construction rejection, post-heart construction, duplicate rejection, six-second production, automatic nearby collection, HUD feedback, and authoritative wood update.
- Visual: built Tidecatcher with stored production, readable HUD status, and no layout regression at 1280x800.

Expected changes: deterministic production rule, composed building node, workbench construction action, HUD status/feedback, world wiring, tests, and synchronized automation docs.

Risk and rollback: per-frame production can become nondeterministic or wasteful. Keep timing in a pure accumulator and give only the single active building lightweight processing; later buildings can move to timer/event batching when a measured consumer exists.

### Milestone 4 evidence — 2026-08-03

- Production unit tests pass: 5 assertions covering sub-interval behavior, exact interval output, chunk-size independence, six-wood cap, and collection reset.
- Tidecatcher integration tests pass: 8 assertions covering unlock, visible construction, duplicate rejection, deterministic production, proximity transfer, authoritative inventory, emptied storage, and feedback.
- Workbench integration additionally verifies focus moves to Build Tidecatcher immediately after crafting unlocks it.
- Reproducible built-state evidence captured at 1280x800 in `evidence/tidecatcher-1280x800.png` with 3/6 stored wood.
- Visual review confirms readable cadence/storage/collection guidance, completed construction state, valid Close focus, no clipping/overlap, bounded camera, and visible building identity.

## Milestone 5: versioned local persistence

Goal: preserve the meaningful run state through a controller-accessible save/load cycle without introducing global state.

Assumptions:

- Schema version 1 covers player health/position, wood, scrap, generated equipment including IDs and seeds, equipped ID, Reinforced Heart, Tidecatcher construction, and stored wood.
- Tree/enemy transient encounter state is not persisted in this milestone; loading restores progression into a fresh arena encounter.
- `user://shardbound-save.json` is the single local slot and requires no text entry.
- Temp-file write plus replace/rollback is the practical atomic strategy available through Godot file APIs.

Acceptance criteria:

- A controller-focused system menu exposes Save, Load, and Close without a pointer.
- Saved JSON declares schema version 1 and contains only serializable values/stable identifiers.
- Successful load deterministically restores every scoped field and refreshes gameplay/UI.
- Malformed JSON, missing required state, and unsupported versions are rejected without mutating the live world.
- Save replacement uses a temp file and preserves/restores the previous file if replacement fails.
- Unit and integration tests cover validation, round trip, disk IO, restoration, rejection, and menu focus/feedback.

Tests defined before production changes:

- Unit: schema emission, valid round trip, malformed rejection, unsupported-version rejection, missing-state rejection, and disk round trip.
- Integration: populate a source world, save, load into a fresh world, verify all scoped fields/building storage/equipment, and verify system-menu focus and visible feedback.

Expected changes: persistence service, world state snapshot/restore, Tidecatcher restoration, system menu, input mapping, tests, save docs, and evidence.

Risk and rollback: partial load mutation could corrupt an active run. Decode and validate the complete payload before applying any field; integration tests load into a fresh composition and assert authoritative state afterward.

### Milestone 5 evidence — 2026-08-03

- Save-service unit tests pass: 8 assertions covering schema emission, semantic round trip, malformed/unsupported/missing-state rejection, and disk round trip.
- Save/load integration tests pass: 13 assertions covering disk IO, health/position/resources, stable item seed/equipped ID/derived damage, progression, construction, stored wood, menu focus/feedback, and mutation-free malformed rejection.
- JSON numeric fields are canonicalized after decoding so integer domain values remain typed and deterministic.
- Reproducible system-menu evidence at `evidence/system-menu-1280x800.png` was recaptured for schema 3 and now shows saved 12/12 health, 5 wood, 2 stone, derived attack 2, 4/6 stored wood, success feedback, and Save focus.
- Visual review confirms readable labels, no clipping/overlap, correct modal layering, visible focus, consistent background HUD state, and no missing assets.

## Milestone 6: first island shard

Goal: prove “the world itself is loot” with one deterministic shard, one physical neighboring slot, and an immediately visible risk/reward modifier.

Assumptions:

- The first enemy drops both its deterministic equipment and the Verdant Crucible shard so the complete decision path is reachable in the existing arena.
- Verdant Crucible adds +1 tree wood yield and multiplies enemy movement speed by 1.25.
- One eastern slot is enough to prove inspect/install/replace/remove architecture; additional slots and adjacency remain later work.
- Save schema advances to 2; schema-1 saves migrate by adding an empty shard inventory and empty installed slot.

Acceptance criteria:

- The fixed shard has stable ID, seed, biome, positive modifier, and negative modifier.
- Controller-only UI inspects and installs, replaces, or removes the shard without pointer input.
- The eastern slot visibly changes when installed.
- Install immediately changes authoritative tree yield and enemy speed; removal restores baseline values.
- Schema 2 persists inventory and installed shard, while valid schema-1 saves migrate without losing prior state.
- Unit, integration, migration, and 1280x800 visual evidence cover the flow.

Tests defined before production changes:

- Unit: deterministic shard generation, stable fields, and explicit modifier values.
- Save unit: schema-2 emission/round trip, schema-1 migration with empty island state, and unsupported schema rejection.
- Integration: shard pickup/panel focus/install/remove, visible slot state, modifier application/reset, and persisted restoration.

Expected changes: shard definition/generator, physical slot, enemy drop, pickup/inventory state, controller panel, modifier wiring, save schema/migration, tests, docs, and evidence.

Risk and rollback: modifiers can drift when repeatedly installing/loading. Always recompute affected values from immutable baselines rather than stacking multipliers.

### Milestone 6 evidence — 2026-08-03

- Island generation unit tests pass: 5 assertions for repeatability, stable seed-based ID, biome, +1 yield reward, and 1.25 speed risk.
- Save tests cover schema-2 emission/round trip and explicit schema-1 migration to empty island state.
- Island integration tests cover pickup/panel focus, install, physical slot state, both modifiers, replace without stacking, removal/reset, schema-2 save/load, and deterministic modifier restoration.
- Enemy-death integration verifies the shard exists as a world pickup alongside equipment.
- Reproducible evidence captured at 1280x800 in `evidence/island-shard-1280x800.png` with Replace focused and the installed eastern island visible.
- Visual review confirms readable name/biome/seed/risk/reward/status, clear controller focus, no clipping/overlap, correct modal layering, and visible world change.

## Milestone 7: ranged enemy and elite variation

Goal: broaden combat pressure with a telegraphed ranged archetype and an elite behavior change, while preserving deterministic scene configuration and island-modifier interaction.

Assumptions:

- The ordinary Tide Slinger maintains distance and fires one projectile after a 0.55-second telegraph.
- The elite Stormcaller uses the same readable telegraph but fires a three-projectile spread; this behavioral difference is the elite proof, not extra health alone.
- Both have fixed spawn positions and explicit loot seeds.
- Verdant Crucible multiplies every enemy movement speed from immutable archetype baselines.

Acceptance criteria:

- Ordinary and elite ranged enemies spawn at documented deterministic coordinates.
- Ranged attacks visibly telegraph before projectiles exist.
- Ordinary volleys contain one projectile; elite volleys contain three deterministic spread angles.
- Projectiles move, damage the player once, and clean themselves up out of bounds.
- Both variants can be defeated by the existing attack and emit deterministic equipment loot.
- Verdant Crucible accelerates chaser, ordinary ranged, and elite movement without stacking.
- Automated tests and 1280x800 combat evidence cover telegraph readability and elite identity.

Tests defined before production changes:

- Unit: ordinary/elite angle patterns, symmetry, fixed telegraph duration, and deterministic attack parameters.
- Integration: fixed spawns, telegraph-before-volley timing, one-versus-three projectile requests, projectile damage, deterministic death loot, and shard speed modifier/reset across all archetypes.

Expected changes: pure ranged attack pattern, ranged enemy scene behavior, projectile, fixed scene instances, world projectile/loot wiring, modifier propagation, tests, combat docs, and evidence.

Risk and rollback: visual telegraphs and projectile collision can become frame-dependent. Keep pattern/timing explicit, test the state transition directly, and use distance-based single-hit projectile behavior suitable for the current collision-light prototype.

### Milestone 7 evidence — 2026-08-03

- Ranged-pattern unit tests pass: 5 assertions for ordinary shot count, elite three-shot count/symmetry, 0.55-second telegraph, and 1.65-second cooldown.
- Ranged integration tests pass: fixed spawns, telegraph-before-volley timing, one-versus-three requests, projectile single-hit damage, deterministic ordinary/elite loot, and all-enemy Verdant speed application/reset.
- The initial implementation exposed an untyped array at the typed volley signal boundary; explicit `Array[float]` construction corrected it and both targeted suites passed afterward.
- Reproducible combat evidence captured at 1280x800 in `evidence/ranged-combat-1280x800.png` with both enemies telegraphing.
- The first capture exposed the ordinary enemy partially under the HUD. Its deterministic spawn moved from `(-390, -190)` to `(-390, -120)` and the artifact was recaptured.
- Final visual review confirms unobscured silhouettes, readable yellow aim lines/wind-up rings, distinct elite crown/ring, bounded arena, no clipping/overlap, and no missing assets.

## Milestone 8: Abyssal Warden boss

Goal: cap the arena encounter with one deterministic boss whose phase transition changes attack behavior, not only health values.

Assumptions:

- Defeating the chaser, Tide Slinger, and Stormcaller unlocks the boss at fixed position `(0, 230)`.
- Phase 1 telegraphs and fires two focused tidal lances.
- At half health, phase 2 changes color/silhouette, raises movement pressure, shortens telegraph time, and fires eight radial Maelstrom projectiles.
- Victory drops one deterministic legendary Riftwake Core, seed `7777`, power 9.
- Boss encounter state remains transient until encounter-state persistence is explicitly scoped.

Acceptance criteria:

- Boss remains hidden/non-interactive until all three current enemies are defeated.
- Entrance and victory provide clear HUD feedback.
- Both phases telegraph before projectiles and use deterministic patterns.
- Crossing half health triggers one visible behavioral transition.
- Verdant Crucible multiplies boss movement speed from its current phase baseline without stacking.
- Boss death produces the fixed legendary reward and cannot signal victory twice.
- Unit, integration, and 1280x800 visual evidence cover unlock, patterns, transition, modifier, and reward.

Tests defined before production changes:

- Unit: phase-1 two-lance symmetry, phase-2 eight-direction normalization/coverage, phase telegraph durations, and deterministic legendary reward.
- Integration: locked initial state, three-enemy unlock, entrance feedback, telegraph-before-fire for both phases, transition speed/pattern, Verdant interaction, boss death, victory feedback, and legendary pickup.

Expected changes: pure boss pattern/reward rules, boss scene behavior, world unlock/projectile/reward wiring, encounter HUD, modifier propagation, tests, combat docs, and evidence.

Risk and rollback: a boss can overwhelm the compact arena. Use explicit low projectile counts/speeds, readable wind-ups, and a small health pool; defer tuning claims until manual playtesting.

### Milestone 8 evidence — 2026-08-03

- Boss-pattern unit tests pass: 6 assertions covering two-lance symmetry, eight-direction normalized Maelstrom, phase telegraph durations, and deterministic legendary reward.
- Boss integration tests cover initial lock, three-enemy unlock/fixed spawn, entrance feedback, both telegraphs and patterns, half-health transition/speed, Verdant phase multiplication, idempotent defeat, victory feedback, and legendary pickup.
- Reproducible phase-two evidence captured at 1280x800 in `evidence/boss-encounter-1280x800.png`.
- The planned fixed spawn moved from `(0, 285)` to `(0, 230)` before capture so the complete radial telegraph remains inside the arena border.
- Visual review confirms readable phase banner, distinct magenta transition silhouette/horns/health bar, eight warning spokes, unobstructed player/world objects, bounded camera, and no missing assets.
- Encounter difficulty and feel remain unclaimed without a manual playtest.

## Milestone 9: repeatable three-wave rift

Goal: add a compact repeatable combat challenge that reuses proven enemies, escalates behavior across three deterministic waves, and rewards repeat runs.

Assumptions:

- Abyssal Warden victory unlocks a physical portal at `(-510, 250)` for the current run.
- Left shoulder / K enters while nearby; the same action retreats from an active run or exits a resolved run.
- Wave 1: two chasers. Wave 2: one chaser and one Tide Slinger. Wave 3: one Tide Slinger and one Stormcaller.
- Completion drops a deterministic Rift Cache whose seed and power advance by run index; failure drops nothing.
- Rift unlock/run state remains transient until schema-3 encounter persistence is separately approved.

Acceptance criteria:

- Locked portal becomes visibly active only after boss victory.
- Entry, retreat, resolved exit, and repeat entry require no pointer.
- Three waves spawn at explicit positions and progress only after all current enemies are defeated.
- Player defeat and retreat produce clear failure feedback and safe cleanup/recovery.
- Completion produces one deterministic run-indexed reward and clear exit guidance.
- Verdant Crucible accelerates all spawned rift enemies from their archetype baselines.
- Unit, integration, simulation, and 1280x800 evidence cover configuration, flow, failure, reward, and repeatability.

Tests defined before production changes:

- Unit: exact wave configurations/escalation, fixed spawn coordinates, and distinct deterministic rewards for successive runs.
- Integration: locked entry, boss unlock, proximity gate, three-wave progression, Verdant speeds, completion/reward, exit/re-entry, player-defeat failure, and enemy/projectile cleanup.

Expected changes: pure rift rules/reward, portal, run controller, dynamic enemy orchestration, player defeat signal, input/HUD feedback, tests, docs, and evidence.

Risk and rollback: dynamically spawned enemies can leak signals/nodes across runs. Track every rift combatant explicitly, disconnect through queue-free cleanup, and assert an empty list after completion/failure/exit.

### Milestone 9 evidence — 2026-08-03

- Rift-rule unit tests pass: 5 assertions covering exact wave compositions, fixed coordinates, escalation, and distinct improving repeat rewards.
- Rift integration tests pass: 14 assertions covering locked/unlocked portal, proximity, three-wave progression, Verdant speeds, completion cleanup/reward/feedback, resolved exit, repeat entry, player-defeat failure, and cleanup.
- Deterministic simulation passes 5 rift assertions and records: 3 waves cleared, reward seed 8801, 2 runs started, second run failed cleanly by retreat.
- Reproducible wave-three evidence captured at 1280x800 in `evidence/rift-wave-1280x800.png` with the unlocked portal, run/wave/enemy status, Tide Slinger telegraph, and Stormcaller telegraph.
- Initial capture showed stale boss-victory feedback during the rift; entry now clears encounter feedback and the artifact was recaptured.
- Final visual review confirms clear portal identity/range, readable wave 3/3 state, unobscured telegraphs, no clipping/overlap, bounded arena, and no missing assets.
- Reward power caps at 9 after three runs to avoid unbounded numeric-only progression.

## Milestone 10: Riftwake Pulse legendary behavior

Goal: make Riftwake Core visibly build-defining by changing every player attack, not only increasing its damage number.

Assumptions:

- Equipping `riftwake_core_7777` grants affix ID `riftwake_pulse`.
- Each attack emits a 115-pixel radial pulse for 2 damage after the primary strike resolves.
- The primary strike target is excluded from the pulse, preventing duplicate damage.
- Pulse targets are ordered deterministically by distance then stable runtime ID.
- The pulse affects ordinary, elite, boss, and dynamically spawned rift enemies through the existing attackable contract.

Acceptance criteria:

- Boss reward data includes stable legendary affix ID, name, and description.
- Equipment comparison visibly describes Riftwake Pulse.
- Equipping/unequipping and save/load correctly derive active legendary behavior.
- An attack creates readable radial evidence and damages every eligible nearby secondary target exactly once.
- Primary and out-of-radius targets are not pulse-damaged.
- Deterministic targeting and world interaction have unit/integration coverage across existing enemy types.

Tests defined before production changes:

- Unit: radius inclusion, exclusion, distance ordering, stable-ID tie break, and affix metadata.
- Integration: equip legendary, primary strike, no duplicate primary hit, one secondary hit, far-target exclusion, visual pulse creation, unequip disable, and save/load restoration of active behavior.

Expected changes: pure pulse targeting, legendary reward metadata, player derived affix state, pulse visual, world attack wiring, equipment UI description, tests, docs, and evidence.

Risk and rollback: area attacks can trigger duplicate death signals or depend on scene-tree ordering. Select stable IDs first, exclude primary before damage, and apply at most one pulse hit per selected ID.

### Milestone 10 evidence — 2026-08-03

- Pulse-targeting unit coverage passes 4 assertions for radius/exclusion, distance order, stable-ID tie breaking, and reward metadata; the unit suite totals 62 assertions.
- Integration coverage passes for equip/unequip, exact primary/secondary/out-of-range damage, boss and live rift-wave interaction, visible effect creation, and save/load restoration; the integration suite totals 109 assertions.
- Full validation passes 181 assertions across unit, integration, and deterministic simulation suites.
- The first targeted run exposed that the test runner could continue after a dependent script failed to compile and report zero assertions as a pass. The runner now records load, compile, or instantiation failures explicitly before dispatching any test.
- Entering a rift now removes hidden arena combatants from `attackable`, preventing attacks or pulses from selecting invisible enemies.
- Reproducible evidence was captured at 1280x800 in `evidence/legendary-pulse-1280x800.png` while the equipment comparison was open.
- Visual review confirms readable wrapped affix text, visible pulse rings, UNEQUIP controller focus, opaque modal layering, no clipping/overlap, bounded arena, and no missing assets.

## Milestone 11: three deterministic island-shard identities

Goal: expand the defining world-loot mechanic from one numeric modifier pair to three deterministic island choices that visibly connect gathering, combat, and automation.

Assumptions:

- Seed selection cycles deterministically from `9001`: Verdant Crucible, Emberglass Reach, then Tempest Loom.
- Verdant remains save-compatible and unchanged: +1 tree yield, ×1.25 enemy movement.
- Emberglass grants +2 player attack but reduces tree yield by 1.
- Tempest halves Tidecatcher production time but adds 1 damage to enemy projectiles.
- The chaser, Tide Slinger, and Stormcaller provide seeds `9001`, `9002`, and `9003` respectively so all choices exist in the playable loop.
- New fields are optional extensions to schema 2; old Verdant-only saves require no migration.

Acceptance criteria:

- Three seeds produce stable IDs, biome identity, descriptions, and distinct modifier data.
- Controller-operable previous/next controls inspect every owned shard and install the selected index.
- Replacing or removing shards recomputes player attack, tree yield, enemy speed, projectile damage, and Tidecatcher cadence from immutable baselines without stacking.
- The physical eastern island changes color and silhouette by installed biome.
- Ordinary and elite ranged deaths drop their documented deterministic shard.
- Saving/loading an installed new shard restores its identity and derived behavior under schema 2.
- Unit, integration, and 1280x800 evidence cover generation, selection, behavior, replacement, persistence, focus, readability, and world identity.

Tests defined before production changes:

- Unit: stable three-seed definitions, deterministic cycling, exact optional modifiers, and production interval application/reset.
- Integration: three-item controller selection, Emberglass attack/tree tradeoff, Tempest production/projectile tradeoff, non-stacking replacement/removal, ranged shard drops, and Tempest save/load restoration.

Expected changes: shard definition generation, optional schema-2 field normalization, Tidecatcher cadence configuration, world modifier/drop wiring, island selection UI, biome-specific slot rendering, tests, docs, and evidence.

Risk and rollback: adding modifiers in multiple systems can leave stale derived state. Keep all application in `_apply_island_modifiers`, reset every supported field to its baseline on each call, and test sequential replacement plus removal.

### Milestone 11 evidence — 2026-08-03

- Shard-generation and production unit coverage passes within a 70-assertion unit suite: three stable seed definitions, deterministic cycling, exact modifier data, doubled/reset production cadence, schema-2 round trip, and malformed optional-field rejection.
- Integration coverage passes within a 123-assertion suite: all three combatant drops, three-item selection, explicit controller focus route, Emberglass and Tempest behavior, sequential replacement/removal resets, projectile risk, biome identity, and Tempest save/load restoration.
- Full validation passes 203 assertions; original fixed-seed smoke and repeat-rift metrics remain unchanged.
- The initial red integration run demonstrated that a runtime test error could return control to the runner after only partial assertions. Each registered test now has an expected assertion-count contract, so interrupted runs become explicit failures.
- Reproducible evidence was captured at 1280x800 in `evidence/three-island-shards-1280x800.png` with Tempest Loom selected and installed.
- Visual review confirms readable reward/risk text, 3/3 selection state, Previous/Next controls, REPLACE focus, opaque modal layering, distinct cyan storm-ring island identity, no clipping/overlap, bounded arena, and no missing assets.

## Milestone 12: controller equipment-inventory browsing

Goal: make every collected weapon inspectable and actionable instead of hard-wiring equipment actions to inventory index zero.

Assumptions:

- Previous/Next buttons cycle through the current authoritative inventory without changing saved gameplay state.
- Equip and Salvage act on the displayed index; Unequip remains a global equipped-slot action.
- Selection clamps after salvage and resets to zero only when the inventory becomes empty.
- An equipped displayed item disables Equip and Salvage, preserving existing destruction protection.
- If an action disables the focused button, focus moves to the next valid equipment action.
- UI selection itself is transient and does not require a save-schema change.

Acceptance criteria:

- The modal shows selected position/count and updates item, power comparison, salvage value, and legendary affix text while browsing.
- Controller focus moves explicitly between selection and actions without a pointer.
- Equip and Salvage signals carry the selected index through world-authoritative inventory rules.
- Equipping, protected salvage, unequipping, salvage removal, selection clamping, attack damage, and remaining inventory identity are covered.
- Installed island attack bonuses remain visible in the equipment/HUD attack readout.
- A 1280x800 artifact verifies three-item selection, readable legendary detail, focus, clipping, and layering.

Tests defined before production changes:

- Unit: equip and salvage a non-zero inventory index while preserving the other item.
- Integration: three collected items, controller Next action, explicit focus route, selected equip, accurate damage/HUD, legendary inspection, selected salvage, protected equipped item, focus recovery, index clamping, remaining-item equip, and combat result.

Expected changes: equipment modal selection controls/state, selected-index signal routing, focus neighbors/recovery, selected-item getters, world attack-HUD synchronization, tests, UI/loot/control docs, and evidence.

Risk and rollback: refreshing after actions can disable the currently focused control or leave selection out of range. Clamp selection before every render and recover focus only when the current control is absent or disabled, preserving deliberate focus on Previous/Next.

### Milestone 12 evidence — 2026-08-03

- Equipment inventory unit coverage passes within a 72-assertion unit suite, including equip/salvage of a non-zero index while preserving the other item.
- Integration coverage passes within a 130-assertion suite: three-item browsing, explicit focus route, selected equip/salvage, actual HUD damage, legendary detail/value, equipped-item protection, focus recovery, clamping, remaining-item equip, and combat damage.
- Full validation passes 212 assertions; fixed-seed smoke and repeat-rift metrics remain unchanged.
- The initial red integration run stopped after 3 of 18 equipment assertions; the assertion-count contract converted the runtime error into an explicit `TEST INCOMPLETE` failure and non-zero command result.
- The first 1280x800 capture exposed a mismatch: Riftwake Core salvaged for 10 scrap but displayed value 1. Salvage values now come from one shared domain rule, integration checks value 10, and the artifact was recaptured.
- Final evidence is `evidence/equipment-inventory-1280x800.png`, showing item 3/3, Riftwake behavior, authoritative salvage value 10, equipped Tideglass Bow, and EQUIP focus.
- Visual review confirms readable text, complete actions/navigation, opaque modal layering, no clipping/overlap, bounded arena, and no missing assets.

## Milestone 13: stone gathering and Runed Whetstone

Goal: complete the slice's second gathering branch with distinct feedback and a meaningful permanent stone sink.

Assumptions:

- A fixed stone outcrop at `(390, -80)` takes three discrete hits, shows progressive cracks, and drops 2 stone.
- The existing attack and magnetic pickup contract are reused; stone receives a distinct gray-blue pickup silhouette.
- Runed Whetstone is a unique workbench recipe costing 2 stone and permanently adding +1 base attack damage.
- The workbench browses Reinforced Heart and Runed Whetstone through controller Previous/Next controls rather than adding a second crowded modal section.
- Stone and the crafted flag are authoritative saved state, advancing saves to schema 3.
- Valid schema-1 and schema-2 saves migrate with `stone = 0` and `runed_whetstone_crafted = false`; schema-1 still gains empty island state.

Acceptance criteria:

- Stone has a distinct fixed node, three-hit/crack progression, drop identity, automatic pickup, HUD count, and no effect on wood.
- Workbench recipe browsing is controller-operable with explicit focus and complete cost/effect/status text.
- Whetstone validation is pure, insufficient/duplicate attempts consume nothing, and success deducts exactly 2 stone.
- The permanent +1 combines deterministically with equipment and island attack bonuses without stacking on refresh/load.
- Schema 3 round-trips stone and the crafted flag; schema 1/2 migrations are explicit and tested.
- Integration and 1280x800 evidence cover gathering, recipe focus/readability, crafting, derived damage, and persistence.

Tests defined before production changes:

- Unit: exact Whetstone cost, insufficient/valid/duplicate outcomes, +1 result, schema-3 round trip, malformed resource rejection, and schema-1/schema-2 migration defaults.
- Integration: stone first-hit crack stage, three-hit pickup, automatic collection/HUD, controller recipe selection/focus, exact deduction, +1 attack, duplicate rejection, and save/load restoration.

Expected changes: stone node scene behavior, world composition/drop/inventory, pickup/HUD identity, workbench recipe selection, crafting rules, derived attack calculation, schema-3 validation/migration, tests, docs, and evidence.

Risk and rollback: permanent derived damage can be double-applied if stored as a computed number. Save only the crafted flag, then derive base attack from equipment, Whetstone, and island state in `_sync_player_equipment`.

### Milestone 13 evidence — 2026-08-03

- Crafting/save unit coverage passes within an 80-assertion unit suite: exact Whetstone validation/results, schema-3 round trip/type rejection, and explicit schema-1/schema-2 defaults.
- Integration coverage passes within a 138-assertion suite: first-hit cracks, three-hit stone drop, distinct pickup/HUD state, recipe browse focus, exact cost, permanent derived attack, duplicate rejection, and save/load restoration with equipment.
- Full validation passes 228 assertions; fixed-seed smoke and repeat-rift metrics remain unchanged.
- The initial red run showed interrupted scenes contaminating later tests. Assertion-contract failure now immediately terminates the runner, preventing downstream false failures.
- `evidence/stone-whetstone-1280x800.png` shows stone 2, a visibly cracked outcrop, recipe 2/2, exact cost/effect/status, and CRAFT focus.
- The first Whetstone capture grazed the objective prompt; the panel moved down 15 pixels and was recaptured without overlap.
- `evidence/system-menu-1280x800.png` was recaptured and visually verifies schema 3, stone 2, attack 2, Save focus, and existing production state.
- Final visual review confirms readable text, controller focus, distinct node silhouette/feedback, no clipping/overlap, opaque layering, bounded arena, and no missing assets.
