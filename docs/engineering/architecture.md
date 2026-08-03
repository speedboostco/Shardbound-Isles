# Architecture

Features use composed Godot scenes. Scene scripts under `game/features` coordinate local behavior; pure deterministic rules live under `game/core`. Authored composition roots live under `game/content`. Definitions remain separate from runtime state. Signals decouple local outcomes such as drops and collection. UI under `game/ui` observes world state and never owns it.

There are no Autoloads in the first playable. The world scene is a composition root, not a general service locator. Save data will use stable IDs, plain serializable values, and an explicit schema version.
