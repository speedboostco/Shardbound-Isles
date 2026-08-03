# INF-003–INF-008 / Gate M0 Evidence

## Outcome by issue

- INF-003: `AGENTS.md` routes a new agent to the seven required, mutually consistent product and engineering documents and explicitly keeps feature detail in `docs/`.
- INF-004: 12 Makefile targets delegate to `tools/dev.ps1`; `help` documents all 12, `GODOT_BIN` configures the editor path, and failed Godot processes propagate exit code 1.
- INF-005: the existing dependency-free runner now records individual cases and writes JUnit XML. Unit, integration, and simulation suites all pass from CLI; a pre-implementation missing RNG script made the unit command exit 1.
- INF-006: the PR workflow defines import, static validation, separate test layers, Windows/Linux matrix exports, JUnit upload, and build artifact upload with missing-artifact failures.
- INF-007: `SeededRngStreams` provides exact-seed generators and stable cached named streams; equipment generation consumes the mechanism. Nine unit assertions cover repetition and stream isolation.
- INF-008: `GameLogger` exposes all six required categories, switchable debug output, always-on contextual errors, and an injectable sink. Event-based loot, world, and save consumers exist; a source audit found no logging inside frame callbacks.

## Validation

- `tools/dev.ps1 static-validate` — exit 0; 18 checks, 0 failures.
- `tools/dev.ps1 test-unit` — exit 0; 110 assertions, 0 failures; `unit.xml` parses with 13 cases.
- `tools/dev.ps1 test-integration` — exit 0; 138 assertions, 0 failures; `integration.xml` parses with 10 cases.
- `tools/dev.ps1 test-simulation` — exit 0; 10 assertions, 0 failures; `simulation.xml` parses with 2 cases.
- `tools/dev.ps1 validate` — exit 0; import and static validation succeeded; 258 assertions, 0 failures; `all.xml` parses with 25 cases.
- Command/help audit — 12 Makefile targets, 0 undocumented targets.
- Source audits — 0 global random calls in `game/core`; 0 per-frame log calls.
- `git diff --check` — run during final review.

## Gameplay reproduction

```text
SMOKE_METRICS {"enemies_defeated":1,"item":{"archetype":"ranged","id":"starter_ranged_424242","name":"Tideglass Bow","power":5,"rarity":"uncommon","seed":424242},"items_collected":1,"seed":424242,"wood":3}
RIFT_METRICS {"first_reward_seed":8801,"runs_started":2,"second_run_status":"failed","waves_cleared":3}
TEST_RESULT suite=all assertions=258 failures=0
```

No player-facing rendering or controls changed, so no new visual capture was required.

## External limitations

- GNU Make is not installed on the current Windows host; the exact PowerShell implementation used by Makefile was validated.
- Local Windows and Linux exports both exit 1 with a clear missing-template error because Godot 4.7.1 export templates are absent. The CI setup requests templates but has not been executed remotely in this task.
- Repository workflow failures can block merges only after the GitHub jobs are selected as required branch-protection checks.
- Godot continues to emit the host-only root certificate store warning without affecting successful import or tests.
