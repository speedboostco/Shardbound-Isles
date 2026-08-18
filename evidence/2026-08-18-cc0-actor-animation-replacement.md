# CC0 actor and animation replacement evidence

Date: 2026-08-18

## Outcome

The hero, melee chaser, ranged enemy, elite, and Warden now use one coherent, professionally authored Tiny Swords CC0 actor family. Runtime atlases are rebuilt deterministically from exact 192x192 source cells into nearest-neighbor 128x128 cells with binary alpha, preventing neighboring-frame bleed and the line artifacts previously visible above moving actors.

## Source and roles

- Source family: Pixel Frog, Tiny Swords Update 010 CC0 edition.
- Retrieved from the Agent Quest CC0 bundle at revision `010c791207c9e5670f07d0fbca3a62f3d1eb0fa7`.
- Local license: `assets/third_party/pixel_frog/tiny_swords_cc0/LICENSE.txt`.
- Local provenance: `assets/third_party/pixel_frog/tiny_swords_cc0/PROVENANCE.md`.
- Blue Warrior: hero.
- Red TNT Goblin: melee chaser.
- Red Archer: ranged enemy.
- Purple Archer: elite ranged enemy.
- Purple Torch Goblin: Warden boss.
- No AI-generated bitmap was added for this replacement.

## Implementation evidence

- `tools/pixel_art_postprocess.gd` builds the committed runtime actor atlases from ignored source sheets using exact source-cell extraction, nearest resizing, and alpha thresholding.
- `game/features/visual_asset_library.gd` maps semantic idle, move, attack, hit, and death states to stable atlas regions.
- Player and enemy presentation scripts animate authored idle/move/attack clips at 8-10 FPS and horizontally flip for facing without changing authoritative movement, hit, collision, cooldown, loot, or save rules.
- Automated tests inspect all five roles and every idle/move/attack frame for non-empty, stable atlas regions.

## Validation

- `tools/dev.ps1 setup`: passed; Godot imported both new runtime atlases.
- `tools/dev.ps1 validate`: passed, `STATIC_RESULT checks=26 failures=0`; `TEST_RESULT suite=all assertions=922 failures=0`.
- `tools/dev.ps1 export-windows`: passed; the package included both actor atlases.
- Exported `build/windows/ShardboundIsles.exe --headless --quit-after 5`: exit code 0.
- `git diff --check`: passed; only Git line-ending notices were emitted.

Godot emitted the environment-specific `Failed to read the root certificate store` warning during CLI validation/export/smoke. It did not change exit codes and the game remains offline.

## 1280x800 visual evidence

- `evidence/cc0-actors-idle-1280x800.png`
- `evidence/cc0-actors-motion-1280x800.png`
- `evidence/cc0-actors-attack-1280x800.png`
- `evidence/handdrawn-island-walking-1280x800.png`
- `evidence/handdrawn-island-combat-1280x800.png`
- `evidence/boss-encounter-1280x800.png`

The captures were inspected at original resolution. All five roles remain readable, motion and attack frames are populated, no atlas seam appears above the hero, no white hit/attack circles return, and actor scale is coherent with the terrain.

## Known limitations

- This CC0 Archer edition has no dedicated walk row; its authored second idle row is used for locomotion, matching the bundle manifest.
- The edition has no dedicated hit/death sheets. Existing hit flash and a stable final-pose fade remain the bounded fallbacks, so they are readable but less expressive than idle/move/attack.
- The Warrior art always visibly carries a sword even when the gameplay HUD reports another weapon or unarmed state.
- Horizontal flip provides left/right facing; logical north/south movement currently shares the same three-quarter presentation instead of dedicated four-direction frames.
- Visual automation was validated at 1280x800, but no physical Steam Deck/controller playtest was performed in this environment.
