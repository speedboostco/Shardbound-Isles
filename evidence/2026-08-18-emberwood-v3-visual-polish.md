# Emberwood v3 Visual Polish Evidence

Date: 2026-08-18  
Mode: OpenAI built-in image generation through the repository-required `imagegen` skill  
Reference viewport: 1280x800

## Outcome

The active Emberwood family now has versioned v3 hero, actor/boss, resource, structure, item, VFX, and terrain atlases. Generated sources were chroma-keyed where applicable, sliced into 64px cells, quantized to the registered 16-color palette, forced to binary alpha, imported losslessly with nearest filtering/no mipmaps, and exposed through semantic lookup. Gameplay authority, collision, saves, and seeded rules were not moved into presentation code.

One attempted broad 8x8 environment sheet was rejected because its first two rows did not preserve a safe grid. It was not copied into the repository. Exact 4x4 resource and structure replacements were generated instead.

## Accepted generated outputs

| Role | Built-in generated output | Workspace source | Runtime derivative |
|---|---|---|---|
| Hero | `C:/Users/vserg/.codex/generated_images/019fc699-8a42-71e2-8311-8cd67ee7113c/exec-7497e0c2-2cf8-4e99-9eed-26cfe98a08b1.png` | `assets/original/emberwood/source/emberwood_hero_v3_master_chroma.png` | `assets/original/emberwood/emberwood_hero_v3_atlas.png` |
| Actors/boss | `.../exec-83ebac39-45a3-4ba4-bb37-a978af238644.png` | `assets/original/emberwood/source/emberwood_actors_v3_master_chroma.png` | `assets/original/emberwood/emberwood_actors_v3_atlas.png` |
| Item icons | `.../exec-3144800a-1e8a-430e-aa0b-196ca169259a.png` | `assets/original/emberwood/source/emberwood_item_icons_v3_master_chroma.png` | `assets/original/emberwood/emberwood_item_icons_v3.png` |
| VFX | `.../exec-c7c81e02-6af1-4c0d-8394-0eed81c430f9.png` | `assets/original/emberwood/source/emberwood_vfx_v3_master_chroma.png` | `assets/original/emberwood/emberwood_vfx_v3_atlas.png` |
| Terrain | `.../exec-fab4cac4-2065-4961-805b-2163a817db6f.png` | `assets/original/emberwood/source/emberwood_terrain_v3_master.png` | `assets/original/emberwood/emberwood_terrain_v3.png` |
| Resources | `.../exec-4e00c2e4-dede-42b0-9ceb-a0fbf9f89600.png` | `assets/original/emberwood/source/emberwood_resources_v3_master_chroma.png` | `assets/original/emberwood/emberwood_resources_v3_atlas.png` |
| Structures | `.../exec-a335e7a2-63f5-4818-825e-668a6f72cea1.png` | `assets/original/emberwood/source/emberwood_structures_v3_master_chroma.png` | `assets/original/emberwood/emberwood_structures_v3_atlas.png` |

The full generated-image folder prefix is the same for every abbreviated entry above. Original built-in outputs were left in place.

## Exact final prompt set

### Hero

> Create a production-ready sprite sheet master for the game Shardbound Isles, matching the attached Emberwood pixel-art atlas as a strict style reference but improving pose clarity, anatomy, lighting, and animation continuity. EXACT LAYOUT: square 8 columns by 8 rows, 64 isolated cells total, perfectly equal cell sizes, no gutters and no overlap. One hero only: a compact top-down three-quarter adventurer with tousled dark brown hair, unmistakable teal cloak and gold scarf, dark ink outline, upper-left lighting. Rows are paired by direction: rows 1-2 south, rows 3-4 west, rows 5-6 east, rows 7-8 north. In the first row of each direction pair: columns 1-4 idle loop with subtle breathing and cloth motion; columns 5-8 first four run frames with strong readable foot contacts. In the second row of each direction pair: columns 1-2 final two run frames; columns 3-6 four attack frames (anticipation, swing, impact, recovery) using a short sword; column 7 hit recoil; column 8 defeated pose. Keep the character centered on the same ground anchor in every cell; no camera drift, no pose crossing cell boundaries. Top-down three-quarter 2D action RPG pixel art, crisp hard pixels, one-pixel-equivalent #172331 outline, compact contact shadow inside each cell, Emberwood colors (pine, moss, teal, cream, gold, ember) with no more than 12 visible colors per sprite, readable at 56 pixels high. FLAT SOLID #ff00ff background in every empty pixel for chroma removal. No transparency, no text, no labels, no grid lines, no UI, no logos, no gradients, no antialiasing, no blur, no watermark, no extra objects.

### Actors and boss

> Create a production-ready 8 by 8 sprite atlas for Shardbound Isles, matching the attached Emberwood top-down three-quarter pixel-art style with stronger silhouettes and smoother animation. EXACT square grid: 8 columns, 8 rows, 64 equal isolated cells, no gutters, no overlap. Rows 1-2 are one cute low forest Slime (moss-green translucent dome, leaf sprout, expressive face): row 1 columns 1-4 idle squash/breathe and columns 5-8 locomotion; row 2 columns 1-2 more locomotion, columns 3-6 attack anticipation/leap/impact/recovery, column 7 hit recoil, column 8 defeated puddle. Rows 3-4 are one upright Forest Ranger (antlered hood, dark green cloak, small bow): identical state layout. Rows 5-6 are the elite Forest Ranger variant, clearly larger silhouette with purple thorn crown and brighter bow: identical state layout. Rows 7-8 are the Abyssal Warden boss, a 90-pixel-feeling ancient armored forest guardian silhouette compressed cleanly into each cell, horned mask, cyan runes and magenta corruption: row 7 columns 1-4 idle pulse, columns 5-8 movement; row 8 columns 1-4 radial attack anticipation/active/recovery, columns 5-6 charge attack, column 7 hit, column 8 defeated collapse. All sprites share consistent ground anchors and upper-left lighting. Crisp handcrafted pixel art, one-pixel-equivalent #172331 outline, compact contact shadow, controlled Emberwood palette plus cyan/magenta boss accents, maximum 12 visible colors per sprite, readable in combat. FLAT SOLID #ff00ff background in all empty pixels for chroma removal. No transparency, text, labels, UI, grid lines, gradients, antialiasing, blur, logos, watermark, loose weapons outside their cell, or extra characters.

### Item icons

> Create a premium item icon atlas for Shardbound Isles, strictly matching the attached Emberwood pixel-art icon family with cleaner silhouettes, richer material highlights, and consistent framing. EXACT LAYOUT: square 8 columns by 8 rows, 64 equal isolated cells, no gutters, no overlap. Exactly one centered icon per cell, identical scale and padding, no cast shadow. Row 1: sword, bow, ember wand, heavy axe, mining pick, spear, shield, quiver. Row 2: helmet, body armor, boots, ring, amulet, gloves, belt, cloak. Row 3: wood bundle, stone cluster, Moonleaf herb, wooden planks, salvage scrap, iron ore, rare spores, obsidian. Row 4: common sword, Magic sword with rune, Rare sword on pointed base, Epic sword with double-diamond shape, Legendary sword with crown/flower shape, common bow, Magic bow, Legendary living bow. Row 5: Chain Mining pickaxe, Burning Smelter ember weapon, Living Arrows bow, Riftwake Pulse relic, Herbal Compass, Runed Whetstone, Reinforced Heart, island shard. Row 6: forest shard, swamp shard, volcanic shard, frozen shard, graveyard shard, settlement shard, arcane shard, unknown shard satchel. Row 7: workbench kit, collector kit, shared-storage kit, lumber-mill kit, Tidecatcher kit, reward chest, favorited heart marker, locked marker. Row 8: empty slot, fallback satchel, health heart, attack emblem, speed boot, critical star, pickup magnet, gathering leaf. Top-down item presentation where appropriate, hard #172331 outline, upper-left light, controlled Emberwood palette, crisp handcrafted pixels, maximum 12 visible colors per cell, immediately identifiable at 48 pixels. FLAT SOLID #ff00ff background in every empty pixel for chroma removal. No transparency, text, letters, numbers, labels, UI panels, grid lines, gradients, antialiasing, blur, logos, watermark, duplicated objects, or icons crossing cell boundaries.

### Animated VFX

> Create a production-ready animated VFX sprite atlas for Shardbound Isles in the exact Emberwood crisp pixel-art style. EXACT LAYOUT: square 8 columns by 8 rows, 64 equal isolated cells, no gutters, no overlap. Every row is one left-to-right 8-frame animation with consistent center and evolving motion: row 1 ordinary hit, compact cream four-point impact star; row 2 critical hit, gold eight-point star plus outer ring; row 3 resource gathering burst, leaf and stone flecks; row 4 enemy death, ember/cyan fragments expanding then fading; row 5 loot pickup, short upward teal/gold pop; row 6 Legendary reward, crown/flower beam rising with a bounded halo; row 7 island materialization, cyan/green runic ring revealing a small island silhouette; row 8 rift pulse, purple/cyan circular energy wave. Clear anticipation/peak/recovery across the eight cells, effect stays within each cell, no external glow or soft bloom. Hard-edged handcrafted pixel art, upper-left light where relevant, dark #172331 accents, controlled Emberwood cream/gold/ember/tide-cyan/purple palette, maximum 12 visible colors per frame, readable over green or dark terrain. FLAT SOLID #ff00ff background for every empty pixel for chroma removal. No transparency, text, labels, UI, characters, weapons, grid lines, gradients, antialiasing, blur, logos, watermark, or effects crossing cell boundaries.

The accepted VFX output produced seven usable phases per row; the runtime atlas therefore deliberately uses a 7x8 contract rather than inventing an eighth frame.

### Terrain

> Create a seamless premium terrain tile master for Shardbound Isles in the attached Emberwood pixel-art style. EXACT LAYOUT: square 4 columns by 4 rows, 16 equal edge-to-edge square cells, no gutters, no outlines around cells. Row 1: three seamless forest grass variants plus a sparse clover variant. Row 2: dirt path center, horizontal path, vertical path, four-way crossing, all matching at shared edges. Row 3: grass-to-dirt transition north edge, south edge, west edge, east edge. Row 4: forest floor with roots, mossy stone floor, shallow teal water, dark rift-corrupted ground. All tiles are top-down, tileable where appropriate, with sparse small-scale pixel clusters and large quiet areas so characters and loot remain readable. Use upper-left light only on embedded stones/roots, controlled Emberwood palette (#214e46 pine, #4d7a4a moss, #76a85b leaf, #8b5a35 earth, #e8d8a8 cream accents, #4db7b3 tide cyan, #b96cff corruption), crisp hard pixel clusters, no gradients and no antialiasing. These are fully opaque terrain cells; fill the whole canvas with tile art. No transparency, magenta background, text, labels, UI, grid lines, borders, characters, props, logos, watermark, perspective walls, or cell separation gaps.

### Resources

> Create a production-ready resource animation sprite atlas for Shardbound Isles, matching the attached Emberwood top-down three-quarter crisp pixel-art family with higher material detail. EXACT LAYOUT: square 4 columns by 4 rows, 16 equal isolated cells, no gutters, no overlap. Row 1: one ancient forest tree across four animation/damage frames—healthy subtle canopy sway A, healthy sway B, visibly damaged with falling leaves, harvested stump/break pose. Row 2: one mossy crystal stone resource across four frames—idle glint A, idle glint B, visibly cracked hit pose, harvested rubble/break pose. Row 3: one Moonleaf herbal resource across four frames—idle sway A, idle sway B, gathered recoil with loose leaf, depleted small roots. Row 4: four readable resource pickup silhouettes—wood bundle, stone cluster, Moonleaf sprig, plank bundle. Keep every object centered on the same ground anchor and fully inside its cell. Strong silhouette at 50 percent scale, upper-left light, compact down-right contact shadow, hard #172331 outline, controlled Emberwood pine/moss/teal/cream/gold/purple palette, handcrafted hard pixels, maximum 12 visible colors per sprite. FLAT SOLID #ff00ff background for every empty pixel for chroma removal. No transparency, text, labels, UI, grid lines, gradients, antialiasing, blur, logo, watermark, characters, or crossing cell boundaries.

### Structures

> Create a production-ready structure and world-interaction atlas for Shardbound Isles in the attached Emberwood top-down three-quarter crisp pixel-art style, with premium material detail and strong readable silhouettes. EXACT LAYOUT: square 4 columns by 4 rows, 16 equal isolated cells, no gutters, no overlap. Row 1: workbench idle, workbench active with cyan rune glow, lumber mill idle, lumber mill active with turning wheel impression. Row 2: resource collector idle, collector active with filled vial, shared storage closed, shared storage visibly full. Row 3: Tidecatcher idle, Tidecatcher charged, island shard pedestal empty, shard pedestal active with green crystal. Row 4: rift portal dormant, rift portal open with cyan-violet center, forest event marker, reward chest open. Every prop centered and anchored consistently, fully inside the cell, readable at 64-96 rendered pixels. Upper-left light, compact down-right contact shadow, hard #172331 outline, controlled Emberwood pine/moss/wood/teal/cream/gold/cyan/purple palette, handcrafted hard pixels, maximum 12 visible colors per prop. FLAT SOLID #ff00ff background for every empty pixel for chroma removal. No transparency, characters, text, labels, UI, grid lines, gradients, antialiasing, blur, logos, watermark, or objects crossing cell boundaries.

## Reproduction and visual review

Run:

```powershell
$env:LOCALAPPDATA='C:\ceer\Shardbound-Isles\.godot-user\local'
$env:APPDATA='C:\ceer\Shardbound-Isles\.godot-user\roaming'
& 'C:\Users\vserg\Downloads\Godot_v4.7.1-stable_win64.exe' --path 'C:\ceer\Shardbound-Isles' --resolution 1280x800 --script res://game/tests/visual/capture_emberwood_v3.gd
```

Artifacts:

- `evidence/emberwood-v3-exploration-1280x800.png`
- `evidence/emberwood-v3-equipment-1280x800.png`
- `evidence/emberwood-v3-structures-1280x800.png`
- `evidence/emberwood-v3-boss-vfx-1280x800.png`
- `evidence/emberwood-v3-island-1280x800.png`

The capture is a deterministic staged visual review, not evidence of physical-controller feel or a continuous play session.

## Validation

- `setup`: project imported all seven v3 runtime rasters successfully.
- `static-validate`: 26 checks, 0 failures.
- `test-unit`: 457 assertions, 0 failures.
- `validate`: import succeeded; 26 static checks and 878 layered assertions passed with 0 failures.
- `export-windows`: debug export succeeded; `build/windows/ShardboundIsles.exe` and `.pck` were produced.
- Exported executable smoke: `ShardboundIsles.exe --headless --quit-after 5` exited 0.

Godot printed the known local root-certificate-store warning during headless commands; it did not affect offline import, tests, capture, export, or smoke.
