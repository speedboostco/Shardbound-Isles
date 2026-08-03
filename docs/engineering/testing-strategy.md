# Testing Strategy

The bootstrap uses a small dependency-free Godot test harness to avoid an unreviewed dependency. Unit tests cover pure rules; integration tests instantiate cooperating nodes; simulation tests drive fixed actions and assert player-facing milestones. All procedural assertions use fixed seeds. Visual checks remain manual until screenshot automation is available.
