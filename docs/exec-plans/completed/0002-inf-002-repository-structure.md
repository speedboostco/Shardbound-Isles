# INF-002 — Repository Structure

## Goal

Move the existing first-playable implementation into the agreed `game/`, `tools/`, and `build/` structure without introducing empty architectural layers.

## Assumptions

- `game/core/` owns the existing deterministic, rendering-independent rules.
- `game/features/` owns reusable gameplay nodes and their scene behavior.
- `game/ui/` owns presentation scenes and scripts; it does not own gameplay state.
- `game/content/` owns authored composition roots, beginning with the existing `world.tscn`.
- `game/tests/` owns the existing automated and visual test harnesses.
- `tools/` owns the existing stable PowerShell command implementation.
- `build/` remains the local export destination and contains only tracked usage metadata; generated exports stay ignored.

## Acceptance criteria

- All required directories have a concrete current responsibility and at least one real artifact.
- `docs/engineering/project-structure.md` documents ownership and dependency direction.
- Godot imports the moved project without new parse or resource errors.
- The complete automated suite passes through the stable command interface.
- No obsolete top-level `src/`, `scripts/`, or `tests/` directory remains.

## Validation

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/dev.ps1 import`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/dev.ps1 validate`
- Inspect the final tree and search for obsolete live resource paths.

## Progress

- [x] Map every existing directory to a concrete destination.
- [x] Move files and preserve Godot UID sidecars.
- [x] Update resource paths, commands, and documentation.
- [x] Run import, tests, and final diff review.

## Result

- Godot 4.7.1 headless import completed with exit code 0 after the move.
- Full validation completed with 228 assertions and 0 failures.
- Every required directory contains a current artifact; obsolete top-level source, test, and script roots are absent.
- The Windows host reports that its system root certificate store cannot be read. This does not affect project import or tests and both commands still exit 0.
- GNU Make is not installed on this Windows host, so `make help` could not be exercised; the underlying `tools/dev.ps1 help` interface completed with exit code 0.
