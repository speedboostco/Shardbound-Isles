# Customer Presentation Actor And HUD Pass

Status: complete

## Goal

Make the first playable visually credible in a customer-facing 1280x800 demonstration by matching the hero silhouette to the equipped weapon, reducing prototype-like HUD obstruction, and preserving the readable licensed Tiny Swords visual family.

## Assumptions and scope

- Reuse the recorded Tiny Swords Update 010 CC0 source already accepted for production presentation; do not introduce another visual family.
- Blue Pawn represents unarmed/gathering, Blue Warrior represents melee, Blue Archer represents ranged, and Purple Pawn plus the existing arcane attack glyph represents magic.
- Equipment changes may alter presentation immediately but must not alter item rules, attack timing, damage, collision, save data, or controller actions.
- This pass targets the always-visible playfield. Full replacement of every modal and dedicated four-direction character art remain separate production work.

## Acceptance criteria

- Unarmed, melee, ranged, and magic equipment select distinct non-blank hero silhouettes during idle, move, and attack.
- Equipping and unequipping refreshes the hero in the same frame without flicker or stale atlas cells.
- The four hero variants share exact 128px cells, bounded six-frame clips, binary alpha, nearest filtering, and a runtime atlas no larger than 2048px per axis.
- The normal HUD occupies materially less playfield, keeps health/resources/weapon readable, and shows controller-first actions without WASD/keyboard debug copy.
- Existing combat, equipment, save, controller, and deterministic simulation tests remain unchanged except for new presentation assertions.
- Raw 1280x800 captures demonstrate all four loadouts and a clean customer-facing combat view.

## Tests defined before implementation

- Unit: canonical weapon-to-hero mapping, exact atlas dimensions, six non-empty idle/move/attack frames for every loadout, and safe fallback.
- Integration: `set_weapon_stats` swaps the runtime atlas block for melee/ranged/magic and unequip returns to unarmed without changing combat stats outside the requested values.
- Visual: deterministic four-loadout showcase plus normal combat capture at 1280x800, inspected for clipping, seams, readability, and HUD obstruction.
- Build: `setup`, targeted unit/integration, full `validate`, Windows export, and exported executable smoke.

## Work sequence

- [x] Audit the current customer-facing frame and licensed source coverage.
- [x] Build the bounded four-loadout hero atlas.
- [x] Bind equipment state and add automated contracts.
- [x] Compact the normal HUD and remove keyboard-oriented presentation copy.
- [x] Capture and inspect the 1280x800 customer-facing scenes.
- [x] Run full validation/export/smoke and record evidence and limitations.
