# Testing Strategy

The bootstrap uses a small dependency-free Godot test harness under `game/tests/` to avoid an unreviewed dependency. Unit tests cover pure rules; integration tests instantiate cooperating nodes; simulation tests drive fixed actions and assert player-facing milestones. All procedural assertions use fixed seeds. Visual scripts produce reproducible 1280x800 artifacts for manual inspection.
