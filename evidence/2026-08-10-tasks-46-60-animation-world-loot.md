# Tasks 46-60 — Animation, Inventory Art, and World-Loot Evidence

Date: 2026-08-10

## Outcome and scope

Tasks 46-53 add the Emberwood v2 animation/icon presentation, shared animation-state rules, target-local interaction feedback, animated resources/pickups/buildings, and a controller-first equipment icon strip/comparison. Tasks 54-59 deliberately reuse the existing M3 `ArchipelagoModel` → shard definition/generator → inventory/preview → slot install → materialized scene → save/load path; no duplicate world model was introduced. Task 60 adds a fixed-seed end-to-end scenario and a bounded island materialization effect.

## Task coverage

| Task | Evidence |
|---|---|
| 46 | Player resolves directional idle/move/attack/hit/death atlas poses; an accepted attack increments one presentation trigger and uses the existing hit event timing. |
| 47 | Slime, Forest Ranger, and elite Ranger bind idle/move/attack/hit/death; death leaves a short fading authored pose while authoritative cleanup remains immediate. |
| 48 | Tree/stone idle and hit motion, pickup bounce/attraction, animated workbench and lumber mill, plus existing break/pickup VFX. |
| 49 | Player reports no persistent selection circle; only a compact elliptical contact shadow and short-lived combat feedback remain. Interaction focus is four target-local brackets. |
| 50-51 | 4x4 64px icon atlas, `icon_id` item data, safe fallback, import/palette validation, and sword/bow/wand/armor/boots/ring/amulet/resources/materials/scrap/shard icons. |
| 52 | Selected identity icon, six-entry icon strip, gold selected border, decision-first gain/cost line, bounded detail scroll, and controller focus at 1280x800. |
| 53 | Shared `AnimationStateRules` vocabulary and priority; visuals never own gameplay outcomes. |
| 54-56 | Existing Node-free deterministic M3 graph, validated shard schema, risk/reward pairing, and 10,000-seed generator stress remain covered. |
| 57-59 | Existing controller shard inspection/slot selection/transactional materialization/persistence now include a shard icon and bounded materialization VFX. |
| 60 | Seed 9001 scenario gathers 3 Wood/2 Stone, defeats two enemies, obtains/inspects/installs Forest in `east`, claims Moonleaf, and restores the claimed island from save. |

## Image generation provenance

- Mode: OpenAI built-in image generation via the repository `imagegen` workflow.
- Style reference: `assets/original/emberwood/emberwood_bootstrap_atlas.png`.
- Generated originals were retained under `C:\Users\vserg\.codex\generated_images\019fc699-8a42-71e2-8311-8cd67ee7113c\` and copied into `assets/original/emberwood/source/`.
- Chroma removal used the standard `remove_chroma_key.py` helper with corner auto-key, tolerance 18, and spill cleanup. Both outputs reported zero partially transparent pixels.
- `tools/pixel_art_postprocess.gd` crops to exact grids, resizes nearest to 64px cells, enforces binary alpha, and quantizes to the registered 16-color palette.

Final animation prompt:

> Use the supplied Emberwood sprite sheet only as a style reference. Create a brand-new square pixel-art animation atlas source on one perfectly flat solid #FF00FF chroma-key background. No transparency, no text, no labels, no borders, no grid lines, no cast shadows outside sprites, no gradients, no anti-aliasing. Exactly 8 columns by 8 rows of separate centered sprites with generous equal gutters; every cell must contain exactly one complete sprite and nothing may cross a cell boundary. Keep the same compact top-down three-quarter fantasy style, dark navy outlines, teal cloth, warm brown leather, coral hit accents, 16-color-ready palette, crisp hard pixel clusters. Layout, left to right: rows 1-4 are the same human hero facing south, west, east, north respectively; in every hero row columns are idle A, idle B, walk A, walk B, attack anticipation, attack follow-through, hit recoil, defeated pose. Row 5 is a green slime: idle A, idle B, move A, move B, attack anticipation, attack lunge, hit recoil, defeated puddle. Row 6 is a hooded forest archer: idle A, idle B, move A, move B, bow telegraph, bow release, hit recoil, defeated pose. Row 7 is the elite version of that archer with a small violet crown crest and brighter silhouette: the same eight states in the same order. Row 8 contains: leafy tree sway left, leafy tree sway right, stone glint A, stone glint B, workbench idle A, workbench idle B, lumber mill idle A, lumber mill idle B. Make state silhouettes unambiguous at 64x64 runtime cells and keep animation pairs consistent rather than redesigning the subject.

Final icon prompt:

> Use the supplied Emberwood sprite sheet only as a style reference. Create a brand-new square pixel-art item icon atlas source on one perfectly flat solid #FF00FF chroma-key background. No transparency, no text, no labels, no borders, no grid lines, no cast shadows outside icons, no gradients, no anti-aliasing. Exactly 4 columns by 4 rows of separate centered icons with generous equal gutters; every cell contains exactly one complete icon and nothing crosses a cell boundary. Same dark navy outline, teal, forest green, warm brown, coral, pale gold and violet accents, 16-color-ready palette, crisp hard pixel clusters, consistent three-quarter RPG inventory icon perspective. Layout left to right: row 1 one-handed sword, wooden bow, ember wand, ironbark helmet. Row 2 teal body armor, swift boots, coral ring, stormglass amulet. Row 3 bundled wood logs, stone chunks, moonleaf herb, sawn wooden plank. Row 4 metal salvage scrap, glowing island shard crystal, generic fallback satchel with a question-mark-shaped clasp but no printed text, empty slot marker represented by a simple dark crossed-diamond token. Make each category unmistakable and readable when downscaled into a 64x64 inventory slot.

## Automated evidence

- `make validate` equivalent: static checks 26/26; all automated tests 874 assertions, 0 failures; JUnit at `build/test-results/all.xml`.
- Unit slice: 453 assertions, 0 failures.
- Integration slice: 335 assertions, 0 failures.
- Simulation slice: 86 assertions, 0 failures.
- Task 60 metrics: `seed=9001`, `wood=3`, `stone=2`, `enemies_defeated=2`, `slot=east`, `installed_biome=forest`, `new_opportunity=moonleaf`, `save_restored=true`.
- Animation stress: 24 enemy plus 32 resource presentations advanced for 60 frames in 9,553 µs on this machine; this is a deterministic smoke metric, not a device frame-time guarantee.
- Windows debug export succeeded and the exported executable completed a headless launch/quit smoke with exit code 0.

## 1280x800 visual evidence

- `tasks-46-60-animation-interaction-1280x800.png`: directional hero attack, enemy telegraphs, resource response, contact shadows, and no persistent player selection circle.
- `tasks-46-60-equipment-icons-1280x800.png`: five distinct item icons plus empty slot, visible selection border, gain/cost comparison, scroll affordance, and all actions inside frame.
- `tasks-46-60-shard-inspection-1280x800.png`: shard icon, biome/level/resources/enemies, positive modifiers, risks, encounter, rewards, free slot, install/cancel controls.
- `tasks-46-60-island-materialization-1280x800.png`: new physical Forest island, enemies/resources/event, and bounded teal/gold materialization ring/beam.

Review result: no text clipping or modal/prompt overlap is visible in the final captures. The item strip and shard card remain readable without hover at the 1280x800 reference viewport. The materialization capture clearly changes the world silhouette and exposes Moonleaf/event content.

## Known limitations

- These are two-frame bootstrap locomotion/attack clips and key-pose hit/death transitions, not final 4-8 frame production animation.
- Attack gameplay resolves immediately in the existing combat contract; the first displayed attack frame is therefore the active/follow-through pose rather than a newly introduced gameplay wind-up.
- No audio was added or evaluated.
- Automated controller focus/navigation passed, but no physical controller or Steam Deck session was run. Feel, stick repeat, comfort, and the experiential Task 45 gate remain human-hardware checks.
