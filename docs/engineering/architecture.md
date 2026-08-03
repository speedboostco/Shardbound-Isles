# Architecture

Features use composed Godot scenes. Scene scripts under `game/features` coordinate local behavior; pure deterministic rules live under `game/core`. Authored composition roots live under `game/content`. Definitions remain separate from runtime state. Signals decouple local outcomes such as drops and collection. UI under `game/ui` observes world state and never owns it.

There are no Autoloads in the first playable. The world scene is a composition root, not a general service locator. `MovementRules`, `InteractionSelector`, `ResourceInventory`, `HealthComponent`, and weapon definition/runtime models are scene-independent contracts with targeted tests. Resource nodes share one definition-driven behavior, while player/enemy scenes compose health and presentation around it. Save data uses stable IDs, plain serializable values, and an explicit schema version.

## Determinism

Domain systems use explicit `RandomNumberGenerator` instances. `SeededRngStreams` creates exact-seed generators and derives cached named streams from a root seed. Advancing one named stream must never change another. Static validation rejects global random calls in `game/core`.

## Logging

`GameLogger` is an injected diagnostic boundary, not authoritative state and not an Autoload. It exposes `GAMEPLAY`, `LOOT`, `WORLD`, `SAVE`, `PERFORMANCE`, and `ERROR`. Debug output is controlled by `shardbound/logging/debug_enabled`; errors are always emitted with structured context. Logging belongs on discrete events, never in `_process` or `_physics_process`.
