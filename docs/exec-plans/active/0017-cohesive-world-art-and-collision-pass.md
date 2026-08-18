# 0017 — Cohesive world art and collision pass

Status: complete (2026-08-18)

## Goal

Replace the visually mismatched protagonist/enemy presentation with one reviewed CC0 family, bring the ground and ordinary world objects into the same palette, and make deliberate solid props stop movement without dealing contact damage.

## Assumptions

- “Same amount of dimensions” means retaining all eight authored facings.
- The runtime contract is the visible set of idle, movement, sword, ranged, magic, hurt, and death actions; unrelated source gestures are not required by gameplay.
- Decorative flowers and ground detail remain non-colliding. Trees, boulders, resources, workstations, and committed buildings are solid.
- Collision is presentation-independent and does not become a damage source.

## Acceptance criteria

- One named hero remains readable at 56–64 rendered pixels in all eight directions.
- Sword, bow, staff/magic, hurt, and death use authored frames from the same body sheet.
- Chaser, ranger, elite, and boss use compatible actors from the same family and resolve eight facings without mirroring.
- Terrain, resources, decorations, and solid border props use the matching Puny palette; at least twelve deliberate world obstacles and twenty-four non-colliding details enrich the opening arena.
- Every solid world obstacle has an explicit shape, stops `CharacterBody2D` movement, and cannot deal contact damage.
- Existing gathering, combat, save, controller, and deterministic contracts remain unchanged.
- Unit/integration validation, 1280×800 captures, full validation, and Windows export pass.

## Test plan

1. Unit: validate Puny atlas dimensions, eight directional lookups, all hero weapon actions, enemy state clips, and semantic terrain/object regions.
2. Integration: instantiate the opening world, assert density/collision contracts, push the player into a solid prop through physics, and prove health is unchanged.
3. Regression: run unit, integration, simulation, full validation, Windows export, and exported executable smoke.
4. Visual: capture an eight-direction/action board and opening-world 1280×800 frame; inspect clipping, scale, palette, path readability, and obstacle placement.

## Source decision

Shade’s Puny Characters and Puny World were selected from their official CC0 distributions. The family uniquely satisfies eight directions plus sword, bow, staff, hurt, and death while also supplying matching terrain, water, trees, rocks, buildings, and resource objects. Image generation remains a fallback only; independently generated animation frames would weaken identity and frame continuity.

## Progress

- [x] Audit current semantic animation and collision boundaries.
- [x] Review official source coverage and license.
- [x] Import bounded runtime assets and provenance.
- [x] Integrate actors, terrain, resources, density, and collisions.
- [x] Run visual and automated acceptance.
- [x] Record evidence and close the plan.
