# Production hero animation pass — 2026-08-18

## Outcome

The player now renders as one coherent Hormelz CC0 armored protagonist in eight authored directions. Runtime presentation retains complete selected source clips for idle, run, four equipment actions, impact, and death. No direction is mirrored, no procedural weapon line or circular hit overlay is present, and procedural body squash was removed.

## Licensed source

- Official source: https://hormelz.itch.io/8-directional-knight
- Author/distributor: Hormelz
- Declared license: Creative Commons Zero v1.0 Universal
- Retrieved free files: `(Free)KnightBasic.rar`, `(Free)KnightAdvCombat.rar`, `(Free)KnightExMovement.rar`
- Explicitly excluded: paid `KnightSword.rar` and `KnightSwordShield.rar`
- Retained source: 33 free animations × 8 directions as PNG plus PixelOver JSON metadata under the `.gdignore` source directory
- Runtime transform and replacement risk: `assets/third_party/hormelz/knight_cc0/PROVENANCE.md`

## Runtime contract

| State/action | Authored source | Frames per direction | Directions |
|---|---|---:|---:|
| Idle | `Idle` | 17 | 8 |
| Move | `Run` | 8 | 8 |
| Unarmed | `Attack` | 15 | 8 |
| Melee | `SpinAttack` | 17 | 8 |
| Ranged | `Draw` | 7 | 8 |
| Magic | `Cast` | 10 | 8 |
| Hit | `Impact` | 9 | 8 |
| Death | `Die` | 27 | 8 |

All runtime cells are 128×128, nearest-filtered, lossless, mipmap-free, binary-alpha, and packed into atlases no larger than 2048×2048. The death sequence uses its full 160px fall envelope reduced nearest-neighbor to prevent clipping. Gameplay collision, movement, cooldown, hit resolution, damage, projectiles, loot, and saves are unchanged.

## Validation

- `tools/dev.ps1 setup`: Godot imported all eight new runtime atlases without parse/import errors.
- `tools/dev.ps1 test-unit`: 482 assertions, 0 failures.
- `tools/dev.ps1 test-integration`: 355 assertions, 0 failures.
- `tools/dev.ps1 static-validate`: 26 checks, 0 failures.
- `tools/dev.ps1 validate`: 932 assertions, 0 failures; includes deterministic unit, integration, simulation, source-isolation, alpha/palette, and atlas-bound checks.
- `tools/dev.ps1 export-windows`: exit 0; `build/windows/ShardboundIsles.exe` and `.pck` produced.
- Exported `ShardboundIsles.exe --headless --quit-after 5`: exit 0.
- The recurring Windows root-certificate-store diagnostic remains environmental and did not change any command exit code.

## Visual review at 1280×800

- `evidence/production-hero-directions-1280x800.png`: all eight distinct authored facings, stable scale/root, no head-line artifact, no mirroring, no white circle.
- `evidence/production-hero-actions-1280x800.png`: physical, spin, draw, cast, mid-impact, and late collapsed death frames; no clipping or overlay circle.
- `evidence/customer-combat-1280x800.png`: normal HUD and live combat composition with the new protagonist; HUD remains in bounds and gameplay silhouettes remain separable.

## Known limitations

- No physical controller or Steam Deck was available, so subjective animation cadence under human input is not claimed.
- The free Knight-Only CC0 release does not include the paid held sword/shield layers. Equipment is communicated by distinct authored body actions, the existing weapon HUD, projectile, and impact presentation; paid files were intentionally not acquired.
- Customer art-direction acceptance is subjective. Automated and captured checks establish technical readiness, not a blind external customer preference test.
