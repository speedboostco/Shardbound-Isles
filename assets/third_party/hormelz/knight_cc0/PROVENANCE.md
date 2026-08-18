# Hormelz 8 Directional Knight provenance

- Author and distributor: Hormelz
- Work: 8 Directional Knight Character, free Knight-Only bundles
- Source: https://hormelz.itch.io/8-directional-knight
- Retrieved on: 2026-08-18 through the official itch.io free-download flow
- Retrieved files: `(Free)KnightBasic.rar`, `(Free)KnightAdvCombat.rar`, and `(Free)KnightExMovement.rar`
- Excluded files: paid `KnightSword.rar` and `KnightSwordShield.rar`
- License: Creative Commons Zero v1.0 Universal; the official source page identifies CC0, `SOURCE_NOTICE.md` records the retrieval statement, and `LICENSE.txt` retains the project copy of the CC0 notice.
- Source retention: all 33 free animations, all eight directions, and their PixelOver JSON frame metadata are retained below `source/`; GIF previews and original RAR containers are omitted as redundant and source-only data is excluded from Godot import/export with `.gdignore`.
- Runtime selection: `Idle`, `Run`, `Attack`, `SpinAttack`, `Draw`, `Cast`, `Impact`, and `Die` are packed from the exact cardinal and diagonal PNG frames into bounded 128px-cell atlases.
- Modifications: normal 256px source frames use the same 128px camera window around the authored root. The complete 27-frame death sequence needs its wider 160px fall envelope and is reduced to the same runtime cell with nearest-neighbor sampling. Frames are packed without filtering; none are synthesized, mirrored, redrawn, or AI-generated.
- Gameplay use: one coherent armored protagonist in eight directions; equipment families choose authored physical, spin, draw, or cast body actions while projectiles, damage, timing, collision, inventory, and saves remain authoritative gameplay systems.
- Attribution: not required by CC0; retained here for provenance and customer due diligence.
- Replacement risk: medium. The hero has a more dimensional rendered-pixel treatment than Tiny Swords enemies and terrain, so final art-direction acceptance depends on the 1280x800 visual review. The semantic library isolates replacement from gameplay.
