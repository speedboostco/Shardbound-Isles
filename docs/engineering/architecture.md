# Architecture

Features use composed Godot scenes. Scene scripts under `game/features` coordinate local behavior; pure deterministic rules live under `game/core`. Authored composition roots live under `game/content`. Definitions remain separate from runtime state. Signals decouple local outcomes such as drops and collection. UI under `game/ui` observes world state and never owns it.

There are no Autoloads in the first playable. The world scene is a composition root, not a general service locator. `MovementRules`, `InteractionSelector`, `ResourceInventory`, `HealthComponent`, and weapon definition/runtime models are scene-independent contracts with targeted tests. Resource nodes share one definition-driven behavior, while player/enemy scenes compose health and presentation around it. Save data uses stable IDs, plain serializable values, and an explicit schema version.

## M2 item model

`ItemBaseRegistry`, `RarityRules`, `AffixRegistry`, and `LegendaryBehaviorRegistry` are authored domain contracts. `LootGenerator` consumes them through an explicit seeded pipeline and produces serializable runtime dictionaries; UI and generators do not hardcode individual affix IDs. Equipment owns six typed slots and derives a new `StatBlock` after every mutation. A stat resolves as `(base + sum(additive)) * product(1 + multiplicative)`, then applies the stat-specific lower bound. Immutable base values are never overwritten by derived results.

Weapon profile data selects range, target shape, and splash through the shared `AttackProfileRules`. Legendary behaviors are small attachable components connected to `LegendaryEventBus`; `LegendaryBehaviorManager` owns their lifecycle and disconnects them on load, replace, or unequip. The world maps behavior events to scene effects, while domain behavior remains independent of visuals.

## M3 world model

`ArchipelagoModel` is the authoritative, Node-free world graph: world seed, stable axial slots, computed neighbors, installed definition/runtime pairs, mutation revision, and active adjacency tradeoffs. `IslandShardDefinition` validates immutable inventory data; `IslandRuntimeState` owns mutable progress. `IslandSlot` and `MaterializedIsland` are projections that can be cleared and rebuilt without changing model identity.

`IslandModifierRegistry` and `AdjacencySynergyRegistry` are authored data. `IslandModifierManager` loads small components by script path and aggregates their effects; world and UI do not switch on modifier IDs. Install, remove, replace, and load are the only adjacency invalidation points, so no graph calculation runs per frame.

## Determinism

Domain systems use explicit `RandomNumberGenerator` instances. `SeededRngStreams` creates exact-seed generators and derives cached named streams from a root seed. Advancing one named stream must never change another. Static validation rejects global random calls in `game/core`.

## Logging

`GameLogger` is an injected diagnostic boundary, not authoritative state and not an Autoload. It exposes `GAMEPLAY`, `LOOT`, `WORLD`, `SAVE`, `PERFORMANCE`, and `ERROR`. Debug output is controlled by `shardbound/logging/debug_enabled`; errors are always emitted with structured context. Logging belongs on discrete events, never in `_process` or `_physics_process`.
