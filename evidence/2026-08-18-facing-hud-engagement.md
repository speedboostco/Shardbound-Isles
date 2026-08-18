# Facing and HUD correction evidence

Date: 2026-08-18

## Reproduction and correction

- The Puny source rows run clockwise, while the runtime previously indexed them using the counter-clockwise semantic direction array. This selected west art for east input and east art for west input.
- `VisualAssetLibrary.PUNY_DIRECTION_ROWS` now explicitly maps east to row 2, west to row 6, and all four diagonals to their authored rows.
- The status health bar previously expanded across the complete VBox width. It now has a fixed 260-pixel width and shrink-begin layout, leaving visible padding inside the 410-pixel status panel.

## Validation

- `test-unit`: 494 assertions, 0 failures.
- `test-integration`: 363 assertions, 0 failures.
- `validate`: 952 assertions, 0 failures; JUnit written to `build/test-results/all.xml`.
- `export-windows`: exit code 0.
- Exported executable headless smoke: exit code 0.
- `git diff --check`: exit code 0.

Godot emitted the environment-specific Windows certificate-store diagnostic during CLI runs; it did not affect results or exit codes.

## Visual evidence

- `cohesive-hero-directions-1280x800.png`: inspected; E faces screen-right, W faces screen-left, and diagonals match their labels.
- `cohesive-world-collision-1280x800.png`: inspected; the 260-pixel health bar retains right padding and all status text remains within the panel.

## Product guidance

Research sources, ethical boundaries, eight prioritized improvements, and playtest measures are recorded in `docs/design/engagement-principles.md`.

## Boundary

No physical controller or Steam Deck was available. Directional art and layout were exercised through deterministic tests and rendered desktop captures at the target resolution.
