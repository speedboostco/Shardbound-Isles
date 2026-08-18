# CC0 Actor And Animation Replacement

Status: complete

## Goal

Replace the visually inconsistent Emberwood hero/enemy animation sheets with one professionally authored web asset family while preserving every gameplay, collision, controller, save, and deterministic timing contract.

## Source and assumptions

- Use the already selected Tiny Swords Update 010 CC0 edition by Pixel Frog, retrieved from the Agent Quest CC0 bundle at recorded revision `010c791207c9e5670f07d0fbca3a62f3d1eb0fa7`.
- Source sheets use authored 192x192 frames. The bundle manifest verifies six populated frames per idle/run row and notes that Archer locomotion intentionally reuses its second idle row because this edition has no dedicated Archer walk clip.
- Runtime roles: Blue Warrior = hero; Red TNT Goblin = melee chaser; Red Archer = ranged enemy; Purple Archer = elite; Purple Torch Goblin = Warden.
- Animation is presentation-only. Hit application, attack cadence, targeting, movement, collision, loot, and persistence remain authoritative in existing systems.

## Acceptance criteria

- Hero, chaser, ranged enemy, elite, and boss all render from the licensed Tiny Swords actor family.
- Idle, move, and attack have six non-blank frames and play at a bounded authored 10 FPS; hit/death fallbacks never show a missing frame.
- Source frames are sliced on exact 192px boundaries into deterministic 128px runtime cells with binary alpha and no neighboring-frame bleed.
- Horizontal facing uses an intentional flip; no accidental weapon/helmet lines appear above actors.
- Combat telegraphs, hit flash, death cleanup, collisions, damage timing, and controller behavior do not change.
- Asset author, source, exact license, selected files, transforms, and replacement risk are recorded.
- Full validation, Windows export/smoke, and raw 1280x800 motion/combat captures pass.

## Tests defined before implementation

- Unit: exact actor-atlas dimensions/cells, six-frame idle/move/attack clips, non-empty frames, binary alpha, and source-family role mapping.
- Integration: normalized animation state transitions still follow gameplay state; elite remains visually distinct; hit/death cleanup and attack semantics remain intact.
- Simulation: existing gameplay and density suites pass unchanged.
- Visual: raw hero walk/attack and mixed enemy attack captures at 1280x800, inspected for clipping, blank frames, bleed, scale, and readability.
- Build: `static-validate`, full `validate`, Windows export, and exported executable smoke.

## Work sequence

- [x] Confirm source/license and recover exact frame layout.
- [x] Import the selected actor sheets and build deterministic runtime atlases.
- [x] Rebind semantic actor states without changing authority.
- [x] Update automated contracts and documentation.
- [x] Capture and inspect 1280x800 motion/combat evidence.
- [x] Run full validation, export, smoke, and record limitations.
