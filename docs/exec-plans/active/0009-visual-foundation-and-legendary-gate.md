# Visual Foundation and Legendary Gate

Status: targeted iteration — physical Task 45 gate pending

## Goal

Complete Tasks 31-45 from `Shardbound_Isles_Tasks_31-45_Visual_Foundation.docx`: replace prominent prototype rendering with one coherent, validated visual baseline and prove three behavior-changing legendary effects through a shared lifecycle-safe runtime.

## Assumptions

- The selected bootstrap family is an original, AI-assisted project asset family rather than an externally downloaded pack. This avoids redistribution and license ambiguity while still enforcing one coherent source and provenance record.
- Existing M2 Chain Mining, Burning Smelter, and Living Arrows behavior is retained and hardened instead of duplicated.
- Fixed-seed automated controller input and visual captures are valid repository evidence; a physical Steam Deck feel test requires human hardware and cannot be claimed by automation.
- Gameplay rules, timing, collisions, and save schema remain compatible unless an acceptance criterion requires a bounded correction.

## Acceptance criteria

- `docs/design/art-direction.md` is the numeric source of truth and `docs/legal/asset-register.md` records exactly one bootstrap family and its use/replacement policy.
- Pixel-art import settings, naming, dimensions, and source-archive exclusion are checked by `make validate`.
- The 1280x800 validation scene and core arena show coherent terrain, animated/readable player and enemies, distinct resources/drops, reusable combat/reward VFX, and one controller-first UI skin.
- Visual state never owns authoritative movement, damage, drops, pickup, salvage, or legendary behavior.
- Legendary attach/detach is idempotent; Chain Mining is bounded/deterministic; Burning Smelter is one-shot and economy-bounded; Living Arrows is capped, deterministic, and lifecycle-safe.
- Fixed-seed unit, integration, simulation, stress, visual, validation, and Windows export evidence is recorded.
- The gate conclusion is explicit and does not hide missing physical-controller or Steam Deck validation.

## Tests defined before implementation

- Unit: art asset validator contracts; facing/visual-state mapping; VFX settings/lifecycle; legendary registry/lifecycle, Chain Mining target uniqueness, Burning Smelter one-shot eligibility, and Living Arrows cap/replacement/expiry policy.
- Integration: representative art scene contract; navigation/collision invariants; resource hit/destroy/pickup feedback; enemy telegraph/death cleanup; VFX cleanup; controller focus/tooltip/salvage skin; equip/use/unequip for all three legendary effects.
- Simulation: fixed-seed controller-only gather/combat/loot/compare/salvage/legendary route plus dense enemies, 200 drops, repeated VFX, repeated equips, and capped summons.
- Visual: deterministic 1280x800 captures for art validation, core loop, dense combat/loot, all three legendary effects, tooltip/comparison, and salvage confirmation.
- Build: full validation and Windows export smoke.

## Work sequence

- [x] Write the art bible, provenance/license register, asset conventions, and authored family manifest.
- [x] Add cohesive project assets, import/render rules, deterministic asset validation, and representative visual scene.
- [x] Integrate player, forest, resource/drop, enemy, combat/reward VFX, and HUD skin without changing authoritative rules.
- [x] Harden the shared legendary runtime and all three effects against lifecycle, recursion, duplication, economy, and cap failures.
- [x] Add layered automated tests, fixed-seed gate simulation, performance metrics, and documentation updates.
- [x] Capture/review 1280x800 evidence, run full validation and Windows export, and record the targeted-iteration conclusion.
- [ ] Run the physical Steam Deck/controller-only ten-minute seed-314159 journey and move this plan to completed only if the experiential gate is evidenced.

## Gate evidence and bounded follow-up

- Repository evidence: `evidence/2026-08-10-tasks-31-45-visual-foundation.md`.
- Final automated result: static checks 26/26; all tests 820/820; Windows export and exported-EXE headless smoke pass.
- Independent reviews: adversarial technical findings corrected; Gameplay QA conclusion is `continue after a targeted iteration`.
- Remaining scope is exactly the physical/human gate described by the final unchecked item. Do not widen it into more content production.

## Risks and rollback

- Generated atlas cells may not align cleanly with gameplay sprites. Keep visuals as composed presentation nodes and retain gameplay collision/state contracts for file-local rollback.
- Dense effects can obscure targets or allocate excessively. Centralize intensity controls, cap lifetimes/counts, and record measured stress metrics before considering pooling.
- Large UI restyling can break focus. Preserve node paths and action wiring, add focus regression checks, and visually inspect all destructive states.
- The physical Steam Deck gate may remain external. Report it explicitly; do not infer success from desktop automation.
