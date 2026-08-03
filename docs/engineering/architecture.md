# Architecture

Features use composed Godot scenes. Scene scripts coordinate local behavior; pure deterministic rules live under `src/domain`. Definitions remain separate from runtime state. Signals decouple local outcomes such as drops and collection. UI observes world state and never owns it.

There are no Autoloads in the first playable. The world scene is a composition root, not a general service locator. Save data will use stable IDs, plain serializable values, and an explicit schema version.
