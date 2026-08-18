# Living World And Animation Polish Evidence

Date: 2026-08-18

## Outcome

- Removed the unconditional procedural weapon line and cleaned six source pixels of neighboring-cell bleed from hero frames. The isolated 1280x800 player capture has no line above the sprite.
- Applied the same selective deterministic bleed cleanup to affected Ranger and stone rows.
- Replaced plus-sign island zones with authored dormant/active rune pedestals and a restrained elliptical halo.
- Added bounded secondary motion to hero, Slime, Ranger, resources, workbench, and active base-building presentation without moving authoritative bodies.
- Added seven controller-targetable living-world props across four mechanics: three Moonleaf Thickets, one Tidewell, one Whispering Shrine, and two Firefly Hollows.
- Effects are gameplay-backed: Moonleaf reward, three-point healing, wood/stone cache, and a single capped elite guardian that rewards Moonleaf on defeat.

## Image generation provenance

- Mode: OpenAI built-in image generation through the `imagegen` skill.
- Style reference supplied to the generation call: `assets/original/emberwood/emberwood_structures_v3_atlas.png`.
- Built-in generated output retained at `C:/Users/vserg/.codex/generated_images/019fc699-8a42-71e2-8311-8cd67ee7113c/exec-fff6c3ec-c625-4266-9a21-dc1eb7bac55d.png`.
- Workspace chroma master: `assets/original/emberwood/source/emberwood_living_world_v1_master_chroma.png`.
- Workspace alpha master: `assets/original/emberwood/source/emberwood_living_world_v1_master_alpha.png`.
- Runtime atlas: `assets/original/emberwood/emberwood_living_world_v1_atlas.png`.

Exact prompt:

> Use case: production game sprite atlas for an existing 2D top-down action RPG. Match the referenced Emberwood structure atlas exactly in visual language: premium handcrafted crisp pixel art, top-down three-quarter view, compact readable silhouettes, dark teal outlines, warm amber highlights, moss green and moon-cyan accents, ornate but uncluttered fantasy craftsmanship. Create an EXACT 4 columns x 4 rows grid of sixteen separate 64x64-style sprite cells, centered consistently with generous transparent-margin-equivalent space between cells. Row 1 is Moonleaf Thicket: idle A, idle B with leaves gently shifted, harvested/pressed-down, luminous regrowing. Row 2 is Tidewell healing spring: idle A, idle B with water shifted, activated bright healing surge, depleted dim basin. Row 3 is Whispering Shrine: dormant A, dormant B with rune flicker, awakened dangerous violet runes, spent dark stone. Row 4 is Firefly Hollow: closed calm hollow A, calm B with a few fireflies shifted, released swarm glowing, cooldown empty hollow. Every state must remain recognizably the same object and changes should read at gameplay scale. No characters, no scenery, no shadows extending into neighboring cells, no UI, no text, no letters, no numbers, no symbols resembling a plus sign, no gradients, no blur, no antialiasing, no painterly rendering, no border or grid lines. Use only flat #ff00ff as the entire background for later chroma removal; do not use #ff00ff anywhere in sprites. Output a square 1024x1024 master image.

Processing:

- `remove_chroma_key.py` removed `#ff00ff` with tolerance 18 and spill cleanup; the alpha master reported zero partially transparent pixels.
- `tools/pixel_art_postprocess.gd` sliced the 4x4 grid to 64px cells, quantized to the registered 16-color palette, and enforced binary alpha.
- The same deterministic tool clears top-edge cell spill from all hero rows, Ranger rows 2/4, and stone row 1 before every runtime rebuild.
- `ArtAssetValidator` includes the living-world atlas and checks dimensions, imports, binary alpha, and the 16-color-per-cell cap.

## Automated evidence

- `tools/dev.ps1 static-validate`: 26 checks, 0 failures.
- `tools/dev.ps1 test-unit`: 471 assertions, 0 failures.
- `tools/dev.ps1 test-integration`: 352 assertions, 0 failures.
- `tools/dev.ps1 test-simulation`: 94 assertions, 0 failures.
- `tools/dev.ps1 validate`: 917 assertions, 0 failures; JUnit at `build/test-results/all.xml`.
- Living-world fixed-route metrics: 7 props, 4 types, 6 non-combat activations, Moonleaf 3, Wood 2, Stone 2, health 7, maximum guardians 1.
- `tools/dev.ps1 export-windows`: exit 0; `build/windows/ShardboundIsles.exe` and `.pck` produced.
- Exported executable headless smoke (`--quit-after 3`): exit 0.

## 1280x800 visual evidence

- `evidence/living-world-polish-exploration-1280x800.png`: real starting composition with living props and rune pedestals.
- `evidence/living-world-polish-interaction-1280x800.png`: Moonleaf interaction, active art, feedback, and controller target.
- `evidence/living-world-polish-depth-1280x800.png`: shrine guardian challenge and active/cooldown state mix.
- `evidence/living-world-polish-island-pedestal-1280x800.png`: authored pedestal replacement at gameplay scale.
- `evidence/living-world-polish-player-clean-1280x800.png`: isolated hero verification with no persistent line or neighboring-cell spill.

The captures drive real scene interactions. The final isolated-player capture intentionally hides other Node2D children only to make the reported line regression visually auditable.

## Known limitations

- Automated controller targeting passes, but no physical controller or Steam Deck was available for subjective input/animation feel review.
- Living-world cooldown/activation state is session-local in this pass; rewards remain bounded during a session, but cooldowns reset after save/load.
- Smoothness is validated through deterministic state/response tests and rendered stills, not a recorded 60 fps motion capture.
