# Tasks 31-45 — Visual Foundation and Legendary Gate Evidence

Date: 2026-08-10  
Godot: 4.7.1 stable  
Reference viewport: 1280x800  
Fixed simulation seed: 314159

## Outcome

Tasks 31-44 have executable repository evidence. The project now has one coherent Emberwood runtime family, deterministic pixel-art validation, an integer-projected camera, production visuals for the core forest loop, five non-color-only rarity cues, a shared UI skin, reusable bounded VFX, and three lifecycle-safe Legendary effects.

Task 45 concludes **continue after a targeted iteration**. Automated controller-action coverage, fixed-seed state transitions, dense-scene captures, full validation, and Windows export pass. A physical Steam Deck/controller-only ten-minute journey, wall-clock journey timings, blind effect recognition, audio/feel review, and a human-observed voluntary play-style change were not available and are not claimed.

## Requirement coverage

| Task | Implemented evidence |
|---|---|
| 31 ART-001 | `docs/design/art-direction.md` defines numeric scale, palette, perspective, light, outline, animation, rarity, VFX, UI, examples, and replacement policy. |
| 32 ART-002 | `docs/legal/asset-register.md` selects exactly one project-original AI-assisted family and records provenance, rights basis, redistribution, coverage, and replacement risk. |
| 33 ART-003 | Nearest/lossless/no-mipmap imports; 2D transform/vertex snapping; camera smoothing disabled; deterministic dimensions, naming, metadata, 16-color and binary-alpha checks; validation scene and Windows smoke. |
| 34-37 | Hero directions/state feedback, forest tiles/decor, resource/drop silhouettes, Slime tell and Ranger attack silhouette integrated without presentation owning gameplay state. |
| 38 VFX-001 | Normal/critical/projectile/resource/death/pickup/reward VFX have distinct contracts, bounded lifetimes and reduced-effects hooks. |
| 39 VFX-002 | Common circle, Magic triangle, Rare diamond, Epic star/beam and Legendary hex/beam are distinct by geometry as well as color; 200-drop ownership remains bounded. |
| 40 UI-004 | Shared theme, four-pixel controller focus, health bar, contained HUD, scrollable comparison, explicit destructive confirmation, and restored encounter/rift status after modal close. |
| 41 LEG-001 | Duplicate-safe attach/detach, shared event bus, configured definition parameters, unknown-ID failure, and cleanup tests. |
| 42 LEG-002 | Four unique targets inside 150 px, stable ordering, 20-tick cooldown, half-power default, non-recursive chain, and target-linked violet presentation. |
| 43 LEG-003 | Burning eligibility and one-shot death invariant; installed-island deaths reach the shared hook; nearby ore or one visible stored charge; the next Stone consumes one charge for exactly one bonus Stone. |
| 44 LEG-004 | Confirmed bow impact only, deterministic 35% roll, three-plant cap, six-second cleanup, target-loss negative test, unequip cleanup, and cap performance measurement. |
| 45 SIM-002 | Seeded simulation, dense visual evidence, independent adversarial and Gameplay QA reviews, full validation and Windows export pass. Physical/human experiential criteria remain external. |

## Image generation provenance

The built-in ImageGen workflow supplied one original master atlas. The runtime derivative is cropped to an exact 4x4 grid, chroma-keyed, and deterministically processed by `tools/pixel_art_postprocess.gd` into the registered 16-color palette with binary alpha. Source masters remain under `assets/original/emberwood/source/` and are excluded from Godot import/export.

Final prompt submitted to the built-in generator:

> Create one cohesive top-down three-quarter pixel-art sprite atlas for an offline fantasy action RPG called Shardbound Isles. Strict 4 by 4 grid on a flat #ff00ff chroma background, every cell isolated and centered with generous empty padding, no cell overlap. Row 1: the same teal-and-gold cloaked adventurer facing south, west, east, north. Row 2: green forest slime idle, slime attack tell, antlered forest ranger idle, ranger ranged-attack tell. Row 3: leafy forest tree, cut stump, pale stone node, compact resource drop. Row 4: seamless grass tile, seamless dirt/path tile, bright hit-burst glyph, magical attacking plant/Legendary emblem. Consistent upper-left key light, dark navy one-pixel-equivalent outlines, controlled Emberwood pine/moss/cream/gold/ember/tide-cyan palette, readable at small gameplay scale. Pixel art only: hard edges, block clusters, no gradients, no antialiasing, no soft shadows, no text, no UI, no logos, no watermark.

Runtime paths:

- `assets/original/emberwood/emberwood_bootstrap_atlas.png` — 256x256, 4x4 cells, 16 total RGBA values including transparency, zero partial-alpha pixels.
- `assets/original/emberwood/forest_tiles.png` — 128x64, two 64px cells, five total RGBA values, zero partial-alpha pixels.

## Automated validation

Environment variable:

```powershell
$env:GODOT_BIN='C:\Users\vserg\Downloads\Godot_v4.7.1-stable_win64.exe'
```

Results:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\dev.ps1 validate` — exit 0.
- `STATIC_RESULT checks=26 failures=0`.
- `TEST_RESULT suite=all assertions=820 failures=0`.
- JUnit: `build/test-results/all.xml`.
- Validation wall time on this host: 19,655 ms, including import, static validation and all suites.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\dev.ps1 export-windows` — exit 0.
- `build/windows/ShardboundIsles.exe --headless --quit-after 2` — exit 0.
- Export artifacts: EXE 102,982,144 bytes; PCK 563,700 bytes.
- The repeated Windows root-certificate-store diagnostic is a host certificate warning; it did not change any command exit code.

Final simulation metrics:

```json
{"bounded_equipment_drops":40,"comparison_opened":true,"dense_enemies":7,"living_plants":3,"movement_steps_to_first_route_completion":308,"plant_cap_stress_usec":1146,"salvage_decision_completed":true,"scripted_controller_navigation_failures":0,"seed":314159,"time_to_first_item_proxy_steps":308,"triggered_effects":["chain_mining","burning_smelter","living_arrows"],"vfx_stress_usec":5961}
```

The `308` value is a deterministic movement-step proxy, not wall-clock time. `scripted_controller_navigation_failures` describes synthetic Godot input/focus checks, not physical-device testing.

## Visual evidence

All files are 1280x800 and were visually inspected after the final palette and HUD fixes:

- `tasks-31-45-art-validation-1280x800.png`
- `tasks-31-45-core-forest-loop-1280x800.png`
- `tasks-31-45-dense-combat-loot-1280x800.png`
- `tasks-31-45-chain-mining-1280x800.png`
- `tasks-31-45-burning-smelter-1280x800.png`
- `tasks-31-45-living-arrows-1280x800.png`
- `tasks-31-45-equipment-comparison-1280x800.png`
- `tasks-31-45-salvage-confirmation-1280x800.png`

Review result: core sprites use hard palette edges; terrain has no grid seams; the HUD contains every resource/weapon row; all five rarity geometries coexist in the dense capture; Chain Mining links actual affected positions; Burning Smelter shows the resulting charge in both world feedback and HUD; Living Arrows shows three capped plants; comparison and salvage actions remain inside frame with visible controller focus.

## Independent review

The adversarial review initially returned **Reject** and identified pre-impact Living Arrows, hidden/unconsumed Smelter value, collapsed rarity cues, unvalidated semi-alpha/over-palette art, fractional camera projection, HUD overflow/status restoration, dead Legendary metadata, and island kill-hook bypass. Each technical finding was corrected and covered by the final 820-assertion suite. Its remaining blocker is the physical/human Task 45 gate.

Independent Gameplay QA, based on the available captures and simulation rather than a hands-on session, rated Living Arrows as the strongest hook and item comparison as the weakest moment. Its conclusion was **continue after a targeted iteration**. It explicitly found that static/staged evidence cannot establish movement feel, audio/hit timing, wall-clock pacing, blind Legendary recognition, physical controller comfort, or voluntary behavior change.

## Bounded remaining gate

One external validation task remains: run an uninterrupted ten-minute new-save journey at seed 314159 on Steam Deck or a physical controller, without explanatory capture overlays. Record Prompt-E checkpoint timestamps, save/exit/reload continuity, focus failures, blind identification of all three Legendary effects, and whether the tester voluntarily changes play style. This is an evidence task, not authorization to add more content.
