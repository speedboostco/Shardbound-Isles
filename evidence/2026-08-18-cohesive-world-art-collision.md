# Cohesive world art and collision evidence

Date: 2026-08-18

## Outcome

- Shade Puny Warrior, Orc, Archer, Mage, Puny World terrain, tree, and flower sources are retained under CC0 provenance.
- The hero exposes eight authored directions and idle, walk, throw, sword, bow, staff, hurt, and death actions on one body sheet.
- Enemies use compatible 32px sheets from the same family.
- Directional Puny World paths, varied grass, 50 non-colliding flora details, 16 solid border props, and seven interactive living props populate the opening arena.
- Trees, boulders, gatherables, workbench, active Tidecatcher, and committed buildings use explicit solid shapes. Collision stops the player and does not damage health.

## Automated validation

- `tools/dev.ps1 static-validate`: 26 checks, 0 failures.
- `tools/dev.ps1 test-unit`: 493 assertions, 0 failures.
- `tools/dev.ps1 test-integration`: 362 assertions, 0 failures.
- `tools/dev.ps1 validate`: 950 assertions, 0 failures; JUnit written to `build/test-results/all.xml`.
- `tools/dev.ps1 export-windows`: completed with exit code 0.
- `build/windows/ShardboundIsles.exe --headless --quit-after 3`: completed with exit code 0.

Godot emitted the environment-specific Windows root-certificate-store diagnostic during CLI runs; it did not change exit codes or validation results.

## Visual evidence

- `cohesive-hero-directions-1280x800.png`: one hero identity in all eight facings.
- `cohesive-hero-actions-1280x800.png`: authored throw, sword, bow, staff, hurt, and death poses.
- `cohesive-world-collision-1280x800.png`: final opening-world density, organic paths, actors, HUD containment, interactive props, and terrain-object presentation.

All three captures are exactly 1280x800 and were visually inspected for filtering, clipping, layering, path readability, stray overlay geometry, and missing assets.

## Boundary

No physical Steam Deck or physical-controller session was available. Controller behavior remains covered by deterministic input tests, not a hardware feel test. Subjective customer acceptance is a human product gate.
