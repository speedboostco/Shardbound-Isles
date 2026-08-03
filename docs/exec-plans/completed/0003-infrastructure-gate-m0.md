# INF-003–INF-008 — Infrastructure Gate M0

## Goal

Complete the repository onboarding, command, testing, CI, deterministic-randomness, and logging contracts required for Gate M0 without changing player-facing balance or save data.

## Existing baseline

- INF-003 documents and `AGENTS.md` already exist and describe the current product.
- INF-004 commands already delegate to `tools/dev.ps1`, discover Godot through `GODOT_BIN`, and propagate Godot failures.
- The dependency-free test runner already has passing unit, integration, and simulation coverage.
- CI currently imports, runs one combined test command, and exports Linux only.
- Equipment generation uses an explicit seed directly, but there is no reusable named-stream mechanism.
- There is no production logging boundary.

## Assumptions

- Keep the existing dependency-free test runner; JUnit serialization is small enough to own locally.
- `build/test-results/` is the default ignored report destination, configurable with `TEST_REPORT_DIR`.
- Named RNG streams are stateful within one `SeededRngStreams` instance and derive stable independent seeds from a root seed and stream ID.
- Logging is an injected `GameLogger` instance, not an Autoload, so authoritative game data never depends on logging state.
- CI can cross-export Windows and Linux from Ubuntu using installed Godot export templates.
- Enforcing a workflow as a required merge check remains a GitHub branch-protection setting outside repository files.

## Acceptance criteria

- The seven minimal product/engineering documents and concise `AGENTS.md` provide sufficient onboarding without chat history.
- Every required `make` target is documented and delegates to a non-interactive command that fails on errors.
- CLI tests write valid JUnit and failed tests fail `validate`.
- Pull requests run import, static validation, each test layer, both exports, and artifact uploads.
- Equal seeds repeat; named streams are reproducible and isolated; domain code has no global random calls.
- Logging exposes `GAMEPLAY`, `LOOT`, `WORLD`, `SAVE`, `PERFORMANCE`, and `ERROR`; debug output is switchable; errors include context; no frame callback emits logs.

## Tests defined before implementation

- Unit: direct seeded sequences repeat; named streams repeat and do not influence each other.
- Unit: disabled debug logs emit nothing; enabled debug logs and errors include category and structured context.
- Unit: JUnit output reports pass/failure counts and XML-escapes names and messages; writing creates a readable report.
- Static: required project directories and main scene exist; `game/core` contains no global random calls.
- Integration/simulation: all existing scene and fixed-seed tests remain unchanged and pass.

## Progress

- [x] Complete gap analysis.
- [x] Add failing unit contracts for JUnit, RNG streams, and logging.
- [x] Implement the three contracts and stable CLI integration.
- [x] Expand CI and synchronize onboarding documentation.
- [x] Run targeted tests, full validation, export checks, and diff review.

## Result

- The red pre-implementation unit run exited 1 when `seeded_rng_streams.gd` was absent, proving test failures propagate through the CLI.
- Static validation passes 18 checks with no global random calls in `game/core`.
- Unit, integration, and simulation suites pass separately and emit parseable JUnit XML.
- Full `validate` passes 258 assertions with 0 failures while preserving the fixed-seed gameplay metrics.
- All 12 Makefile targets appear in `help`; GNU Make itself is unavailable on the current Windows host, so the PowerShell implementation was exercised directly.
- Both local export commands correctly exit 1 because Godot 4.7.1 export templates are not installed. CI installs templates and defines both artifact-producing exports, but no remote workflow run was available in this task.
- Repository work for INF-003 through INF-008 is complete. Operational Gate M0 still requires a successful CI run or local template installation to produce and inspect a Windows artifact, plus required-check configuration in GitHub branch protection.
