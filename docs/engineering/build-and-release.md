# Build and Release

Stable commands are exposed through `Makefile` and `tools/dev.ps1`. `GODOT_BIN` may identify a Godot executable; otherwise the script searches PATH and common local locations. Debug exports target Windows and Linux under `build/`. Generated export files are ignored. Publishing always requires human approval.

All commands are non-interactive except `run`, which launches the game. `validate` performs headless import, static validation, and all tests. Test commands write JUnit XML to `build/test-results/` by default; `TEST_REPORT_DIR` overrides that destination. A failed Godot process or report write propagates a nonzero exit code.

Local exports require Godot export templates matching the selected editor version. CI installs templates, cross-exports both platforms, and uploads `windows-debug` and `linux-debug` artifacts. Repository jobs fail when a stage or artifact is missing; configure the GitHub `Import, static validation, and tests` and both export jobs as required checks in branch protection to block merges.
