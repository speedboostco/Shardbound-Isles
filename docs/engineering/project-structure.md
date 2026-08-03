# Project Structure

The repository groups runtime code, authored content, and tests under `game/` so every Godot resource path has one stable root:

```text
game/
  core/
  features/
  ui/
  content/
  tests/
docs/
tools/
build/
```

## Responsibilities

- `game/core/` contains deterministic, rendering-independent rules and serializable state services. Current examples include loot generation, crafting, island generation, rift rules, and save schema handling. Code here must not depend on scenes or UI.
- `game/features/` contains reusable gameplay nodes and scene-facing behavior, including the player, enemies, resources, automation, rifts, and world orchestration script.
- `game/ui/` contains presentation scenes and scripts. UI observes gameplay state and emits intent; it does not own authoritative state.
- `game/content/` contains authored composition roots that assemble features and UI. The current `world.tscn` is the first-playable content entry point.
- `game/tests/` contains the dependency-free runner plus unit, integration, simulation, and visual validation scripts. Tests may depend on any production layer; production code must not depend on tests.
- `docs/` is the product, design, engineering, decision, and execution-plan system of record.
- `tools/` contains repository-local developer command implementations. `dev.ps1` backs the stable `make` interface, and `static_validate.gd` enforces repository and deterministic-domain invariants.
- `build/` is the local destination for generated Windows and Linux exports. Generated output is ignored; its tracked README and `.gdignore` document and enforce that responsibility.

Supporting root entries have concrete repository roles: `project.godot` and `export_presets.cfg` configure Godot, `Makefile` exposes stable commands, `.github/` defines CI, and `evidence/` stores approved reproducible review artifacts.

## Dependency direction

`game/content` composes `game/features` and `game/ui`; features may use `game/core`; UI may observe features and core data without becoming authoritative. `game/core` stays independent from Godot scene composition. Cross-layer dependencies must follow this direction unless an accepted decision explicitly changes it.

Do not add a new directory as a placeholder. Add one only when a current artifact has a distinct owner that does not fit an existing responsibility.
