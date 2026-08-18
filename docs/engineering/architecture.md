# Architecture

Features use composed Godot scenes. Scene scripts under `game/features` coordinate local behavior; pure deterministic rules live under `game/core`. Authored composition roots live under `game/content`. Definitions remain separate from runtime state. Signals decouple local outcomes such as drops and collection. UI under `game/ui` observes world state and never owns it.

Presentation rasters are isolated behind semantic libraries. `VisualAssetLibrary` maps actor states/facing, resources, structures, terrain, and bounded VFX to registered Puny/Emberwood cells; `ItemIconLibrary` maps data-owned `icon_id` values. Gameplay scenes may advance presentation elapsed time, but atlas frames never own movement, hit timing, damage, rewards, interaction, collision, or persistence. Versioned atlas siblings make art replacement local and preserve previous families for rollback until visual acceptance.

There are no Autoloads in the first playable. The world scene is a composition root, not a general service locator. `MovementRules`, `InteractionSelector`, `ResourceInventory`, `HealthComponent`, and weapon definition/runtime models are scene-independent contracts with targeted tests. Resource nodes share one definition-driven behavior, while player/enemy scenes compose health and presentation around it. Save data uses stable IDs, plain serializable values, and an explicit schema version.

## M2 item model

`ItemBaseRegistry`, `RarityRules`, `AffixRegistry`, and `LegendaryBehaviorRegistry` are authored domain contracts. `LootGenerator` consumes them through an explicit seeded pipeline and produces serializable runtime dictionaries; UI and generators do not hardcode individual affix IDs. Equipment owns six typed slots and derives a new `StatBlock` after every mutation. A stat resolves as `(base + sum(additive)) * product(1 + multiplicative)`, then applies the stat-specific lower bound. Immutable base values are never overwritten by derived results.

Runtime item identity is canonicalized as `instance_id`; `item_id` and `id` remain serialized compatibility aliases. `LootDropDecision` derives its own explicit stream from seed plus encounter context. Affix eligibility is a pure diagnostic query over slot/base type, allowed/required/excluded item tags, level/tier bounds, duplicates, and conflict groups. Results and rejection reasons are stable regardless of selected-affix iteration order.

`EquipmentInventory` rejects duplicate owned IDs and emits inventory/equipment mutations. Salvage is a two-phase domain transaction (`plan_salvage` then `commit_salvage`) bound to a stable item ID and deterministic reward; stale, protected, equipped, or duplicate commits do not mutate state. `ItemTooltipPresenter` maps item/comparison data into presentation-only text structures so the HUD never calculates authoritative item rules.

Weapon profile data selects range, target shape, and splash through the shared `AttackProfileRules`. Legendary behaviors are small attachable components connected to `LegendaryEventBus`; `LegendaryBehaviorManager` owns their lifecycle and disconnects them on load, replace, or unequip. The world maps behavior events to scene effects, while domain behavior remains independent of visuals.

Sword and wand resolve their deterministic target shapes immediately. Bow attacks materialize a tracked `PlayerWeaponProjectile` that applies its one resolved hit on impact. Any outstanding player projectile is removed when the equipped weapon identity changes.

## M3 world model

`ArchipelagoModel` is the authoritative, Node-free world graph: world seed, stable axial slots, computed neighbors, installed definition/runtime pairs, mutation revision, and active adjacency tradeoffs. `IslandShardDefinition` validates immutable inventory data; `IslandRuntimeState` owns mutable progress. `IslandSlot` and `MaterializedIsland` are projections that can be cleared and rebuilt without changing model identity.

`IslandModifierRegistry` and `AdjacencySynergyRegistry` are authored data. `IslandModifierManager` loads small components by script path and aggregates their effects; world and UI do not switch on modifier IDs. Install, remove, replace, and load are the only adjacency invalidation points, so no graph calculation runs per frame.

## M4 base model

`RecipeRegistry` is the authored crafting source; `CraftingService` creates atomic transaction plans without owning inventory or UI. `BasePlacementModel` serializes committed stable socket state and deliberately excludes preview presentation. `SharedStorage`, `LumberMillSimulation`, `CollectorSimulation`, `OfflineAutomation`, and `ItemUpgradeService` are pure deterministic rules under `game/core`.

The world composition root applies successful transactions and materializes `BaseBuildingVisual` projections. Collector, storage, and mill communicate through accepted/remainder quantities, so capacity boundaries cannot destroy resources. A single timer requests bounded batches; remote buildings never require independent per-frame callbacks. Save schema 7 owns the complete committed simulation state, learned technology IDs, and mana state and applies catch-up only after validation.

`TechnologyTree` and `ManaPool` are Node-free authoritative rules. Technology definitions own stable graph coordinates, semantic icon IDs, prerequisites, and recipe-unlock IDs in addition to cost/effect data. `TechnologyTreeView` dynamically projects the authored four-tier graph and status colors; the HUD only browses view data and emits a learn request, never granting a technology or deducting costs. The world applies a successful transaction, recalculates derived effects, and changes enemy activity only on that event. Production bonuses scale the elapsed input entering the existing bounded `OfflineAutomation` path. `WeaponAimIndicator` and `WeaponCastVisual` are disposable presentation nodes and never perform targeting or damage. `ContactShadow` is a presentation-only profile/renderer shared by ground-bound actors and props; its validated local baseline prevents detached shadows and it has no collision or gameplay authority.

## Visual foundation

`VisualAssetLibrary` is the semantic boundary for Shade's Puny Warrior/Orc/Archer/Mage sheets, Puny World terrain/object cells, and Emberwood interaction/VFX atlases. Hero equipment selects authored throw/sword/bow/staff columns on the same body sheet; no source filename, atlas cell, or presentation elapsed time enters a save. `PlayerCharacter.set_weapon_stats` invalidates only the cached visual region when equipment changes; attack profiles, damage, collision, and timing remain authoritative elsewhere. Gameplay nodes compose presentation-only `Sprite2D` children while retaining collision, health, target, movement, reward, and serialization contracts. `FacingRules` is the pure deterministic eight-direction mapping. `AnimationStateRules` provides shared `idle/move/attack/hit/death` priority, looping policy, and frame math; actor bindings read authoritative flags but never advance transforms, emit hits, choose targets, award loot, or decide cleanup. Solid terrain/building nodes use explicit `StaticBody2D` shapes; visual transparency never defines collision and collisions never emit damage.

`ItemIconLibrary` resolves semantic 64px icon cells and owns the fallback contract. Item definitions and generated instances carry `icon_id`; the HUD and world pickups request icons from data rather than branching on item names. The animation and icon atlases are presentation dependencies and do not enter save state.

`GameplayVfx` owns only a short kind/lifetime and always self-cleans. The world spawns normal hit, critical, projectile, gathering, resource-break, pickup, reward, and death presentation after authoritative events. `VfxSettings` is an injected project-settings snapshot that centralizes reduced-effects intensity and screen-shake scaling without an Autoload. The HUD consumes one shared Theme for buttons, focus, panels, and health presentation; it remains an observer of domain state.

`LivingWorldPropRules` owns the four authored prop definitions and bounded effect/cooldown data. `LivingWorldProp` implements the existing `interactable` contract, local visual state, and cooldown before emitting an effect request. The world composition root applies authoritative resource, healing, cache, or guardian effects. Guardian references are capped and cleared on defeat; prop animation never grants rewards or spawns combatants by itself.

Source masters are excluded from import/export. `ArtAssetValidator` checks every registered runtime raster for lowercase naming, bounded cell-aligned dimensions, lossless/no-mipmap import metadata, project nearest filtering, source isolation, raw archive exclusion, binary alpha, and the per-family palette ceiling during `static-validate`.

## Legendary effect runtime

Stable effect definitions include bounded parameters and separate scripts. `LegendaryBehaviorManager.sync` canonicalizes duplicate IDs, is idempotent for an unchanged loadout, and owns every attach/detach. `LegendaryEventBus` exposes attack, hit, critical hit, kill, resource hit, resource destroyed, resource used, and temporary-expiry hooks; payload copies prevent effect code from mutating the caller.

Chain Mining consumes authored radius/power/cap/cooldown parameters and filters duplicate IDs before stable distance/ID ordering. Burning Smelter owns a per-activation resolved-death set and can consume one ore or create one visible, non-recursive charge; that charge is consumed by the next Stone pickup for exactly one bonus Stone. Living Arrows consumes authored chance/cap/lifetime parameters and listens to confirmed bow hits, never predicted attacks; world summons expire and are actively cleaned when the effect is removed. Installed-island deaths use the same authoritative kill hook. VFX observe effect triggers but never grant damage or rewards.

## Determinism

Domain systems use explicit `RandomNumberGenerator` instances. `SeededRngStreams` creates exact-seed generators and derives cached named streams from a root seed. Advancing one named stream must never change another. Static validation rejects global random calls in `game/core`.

## Logging

`GameLogger` is an injected diagnostic boundary, not authoritative state and not an Autoload. It exposes `GAMEPLAY`, `LOOT`, `WORLD`, `SAVE`, `PERFORMANCE`, and `ERROR`. Debug output is controlled by `shardbound/logging/debug_enabled`; errors are always emitted with structured context. Logging belongs on discrete events, never in `_process` or `_physics_process`.
