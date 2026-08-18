# Production Hero Animation Pass

Status: complete

## Goal

Replace the partial loadout skin swap with one presentation-quality protagonist whose authored directional movement, attack, hit, and death motion remains coherent throughout the first playable.

## Assumptions and scope

- Use a freely redistributable web-sourced character only after recording the exact author, source page, license, selected files, transformations, and replacement risk.
- The selected source is Hormelz's free knight-only CC0 release: it provides eight directions and 33 coherent animations on 256px canvases. This pass imports only the free bundles and does not purchase or redistribute the paid sword/shield variants.
- The runtime uses the four cardinal directions already supported by gameplay. Diagonal source frames remain available for future direction work only when present in the selected free archive; they do not change movement rules in this pass.
- Idle, run, attack, impact/hit, cast, and death are presentation bindings. Gameplay timing, collision, damage, equipment, saves, controller actions, and deterministic rules remain authoritative in existing code.
- One consistent knight body is more important than mixing incompatible hero families. Equipped weapon family remains readable through authored action choice and bounded equipment accents where the free source does not include a held weapon.

## Acceptance criteria

- The hero uses the same identifiable high-resolution knight in every cardinal direction and every runtime state.
- Idle, run, melee/ranged/magic attack, hit, and death use non-blank multi-frame source animation; unarmed/melee may share a coherent physical attack where licensing excludes the paid weapon layer.
- Animation transitions restart exactly once on accepted attack/hit/death events, loop only for idle/run, and never move the collision body.
- The source canvas is normalized without seams, sprite-line artifacts, soft filtering, clipped weapons/effects, or white circular overlays.
- All imported files have explicit CC0 provenance and are mechanically excluded from exports when they are source-only.
- A deterministic 1280x800 evidence scene shows all cardinal idle/run/attack/hit/death states and normal gameplay remains readable.

## Tests defined before implementation

- Unit: every hero weapon/state/direction exposes the expected authored frame count, uses the production atlas, and resolves to in-bounds non-empty regions.
- Unit: attack/hit/death clips do not loop while idle/run clips do; all atlas sizes remain within the 2048px texture budget.
- Integration: accepted attack, real damage, defeat, equipment swap, and direction change refresh the expected hero state without changing combat authority or creating overlay circles/weapon lines.
- Visual: deterministic 1280x800 hero animation contact sheet and live combat capture inspected for seams, clipping, scale, focus, silhouette, and HUD overlap.
- Build: targeted tests, full `validate`, Windows export, and exported executable smoke.

## Work sequence

- [x] Select and archive the exact free CC0 source and license evidence.
- [x] Build bounded runtime atlases and verify every source frame.
- [x] Bind eight-direction states and equipment actions to the protagonist.
- [x] Add unit/integration animation-contract coverage.
- [x] Capture and inspect 1280x800 evidence.
- [x] Run full validation/export/smoke and update design, architecture, legal, and vertical-slice records.
