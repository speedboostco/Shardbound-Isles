# M4 — Crafting, Base, and Automation

Status: completed — 2026-08-09

## Goal

Prove the M4 gate: manual gathering funds a controller-first compact base, the base removes a mastered wood-processing/collection chore through deterministic bounded simulation, and equipment can be safely upgraded without erasing its build identity.

## Assumptions

- The existing Tidecatcher is migrated into the first placeable lumber mill instead of keeping two overlapping wood-production buildings.
- The first base supports one lumber mill, one collector, and one shared storage. This proves multi-building flow without introducing conveyors.
- A lumber mill consumes raw `wood` and produces `plank`; the collector gathers only ordinary `wood`, `stone`, and `moonleaf` resource pickups, never equipment, shards, or encounter rewards.
- Placement uses authored build sockets and 90-degree rotation. Sockets provide deterministic collision/occupancy validation without speculative free-form tile infrastructure.
- Offline catch-up uses a monotonic saved simulation timestamp plus a bounded caller-supplied elapsed duration. Negative time is clamped to zero and catch-up is capped at four hours.
- Item upgrades are deterministic from +0 to +10, preserve affixes and legendary effects, require `scrap`, and require `moonleaf` from +7 onward. There is no failure roll or item destruction.

## Acceptance criteria

- Recipes are data-driven, include inputs/output/station/unlock requirements, reject unknown IDs, and consume inputs only after output can be committed.
- Three useful workbench recipes remain controller-operable with exact missing-resource feedback.
- Placement has visible valid/invalid preview, controller rotation, player/building overlap rejection, and serializes only committed building state.
- Lumber mill production is fixed-step and FPS-independent, has separate input/output inventories and visible progress, and resumes from saved progress.
- Collector has bounded radius/capacity/targets, excludes player-owned and rare rewards, and works through batch simulation rather than per-target frame processing.
- Shared storage moves resources between the collector and lumber mill with explicit flow direction and a safe blocked-output state when full.
- Offline/offscreen simulation is deterministic, capped by capacities, event-driven, bounded, and clamps negative/system-clock rollback.
- Equipment upgrades preview exact cost/result, require a second confirmation, preserve affixes, cap at +10, and use a tested non-dominant formula.
- Save schema migrates M3 state and round-trips all committed base, crafting, automation, and upgrade state.
- Unit, integration, simulation, visual, import, full validation, Windows export, and Linux export evidence is recorded.

## Tests defined before production changes

- Unit — recipe registry/service: authored definitions, unknown input/output/station/unlock validation, missing-cost detail, atomic success, blocked output rollback.
- Unit — placement: socket occupancy, player/building collision, rotation normalization, committed-state serialization without preview.
- Unit — production/storage: chunk-independent lumber processing, distinct inventories, progress restore, shared-storage routing, full-output safe block.
- Unit — collector/offline: ordinary-resource filters, rare/player-owned exclusions, radius/batch limits, four-hour cap, clock rollback clamp, deterministic chunk equivalence.
- Unit — upgrades: +0..+10 cost/power formula, rare-resource threshold, preview, confirmation contract, cap, no destruction, affix/legendary preservation.
- Unit — persistence: schema-6 migration and complete round trip for buildings, storage, production progress, and upgraded equipment.
- Integration — controller workbench/placement/rotation, invalid preview, two buildings, visible flow/progress, safe overflow, save/load continuation, upgrade preview/confirmation.
- Simulation — fixed M4 route from gathered wood through placement, collection, processing, storage, upgrade, save/load and deterministic catch-up.
- Visual — 1280x800 base/placement and upgrade-preview captures with focus/readability/clipping review.

## Implementation sequence

1. Add failing M4 contracts to the dependency-free runner.
2. Implement pure recipe, placement, storage, automation, offline, and upgrade rules.
3. Compose placeable buildings and controller-first HUD flows into the existing world.
4. Advance save schema with migration and restore committed simulation state.
5. Run targeted and full validation; capture visual evidence and exports.
6. Synchronize architecture, controls, testing, performance, vertical-slice, and evidence documents; review the diff and mark this plan complete.

## Risks and rollback

- Save migration can mutate state partially. Decode and validate the entire schema-6 payload before world application.
- Automation can duplicate or lose resources at capacity boundaries. Transfers use accepted/remainder results and commit consumption only when output space exists.
- Modal and placement focus can conflict. The world remains authoritative and restores gameplay only when no modal/placement state is active.
- Catch-up can become an exploit. Clamp negative elapsed time, cap the duration, and test the same elapsed interval across different batch sizes.

## Completion evidence

- Full validation passed: import, 24 static checks, 680 assertions, 0 failures, JUnit written.
- M4 layers passed: recipe/placement/automation/upgrade/save unit contracts; 28-assertion physical integration; 10-assertion deterministic simulation.
- Fixed metrics: 2 buildings, 8-item collector batch, 3 planks, +1 upgrade, schema-6 round trip, no serialized preview.
- Three reviewed 1280×800 artifacts cover invalid placement, physical base flow, and upgrade confirmation.
- Windows and Linux exports completed; isolated Windows exported-binary smoke exited 0.
- System-of-record docs and `evidence/2026-08-09-m4-crafting-base-automation.md` describe behavior, commands, results, and limitations.
