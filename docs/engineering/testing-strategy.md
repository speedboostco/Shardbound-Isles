# Testing Strategy

The project uses a small dependency-free Godot test harness under `game/tests/` to avoid an unreviewed dependency. Unit tests cover pure rules; integration tests instantiate cooperating nodes; simulation tests drive fixed actions and assert player-facing milestones. All procedural assertions use fixed seeds. Visual scripts produce reproducible 1280x800 artifacts for manual inspection.

Every CLI test command writes a JUnit report under `build/test-results/`; set `TEST_REPORT_DIR` to choose another directory. A missing script, compile failure, assertion failure, incomplete assertion contract, or report-write failure returns a nonzero exit code. `validate` imports the project, runs static validation, and then runs the complete test suite.

CI runs import, static validation, unit, integration, and simulation steps separately so logs identify the failing layer. JUnit reports and successful platform exports are retained as workflow artifacts.

To add a test, create a deterministic script in the matching `game/tests/<layer>/` directory, implement `run(support)` for unit tests or `run(support, scene_tree)` for asynchronous scene tests, and register its path and exact assertion count in `game/tests/run_tests.gd`. Run the narrow layer first, then `make validate`.

The M1 simulation repeats the same fixed-seed route from spawn to tree, stone, first Slime, weapon pickup/equip, and second Slime. It asserts exact repeatability, inventory totals, two deaths, one optional item drop, canonical item state, and fewer equipped hits. The M1 scene contract separately measures coalescing 100 resource drops and validates actual input actions, camera behavior, interaction, attack cooldown, and Slime state.
