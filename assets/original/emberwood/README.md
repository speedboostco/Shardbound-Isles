# Emberwood Production Family

This is the one selected bootstrap family for Tasks 31-45. Runtime code accesses semantic cells through `game/features/visual_asset_library.gd`.

The runtime 256x256 PNG is a 4x4 atlas of 64x64 cells. The excluded alpha source master is 1252x1252 with 313x313 cells:

| Row | Column 0 | Column 1 | Column 2 | Column 3 |
|---|---|---|---|---|
| 0 | hero south | hero west | hero east | hero north |
| 1 | slime idle | slime attack | ranger idle | ranger attack |
| 2 | tree | stump | stone | resource drop |
| 3 | grass tile | dirt tile | hit burst | Legendary plant emblem |

Import contract: nearest filtering, no mipmaps, lossless compression, no repeat, alpha enabled. Runtime regions are scaled to the numeric targets in `docs/design/art-direction.md`; collision and gameplay timing remain separate.

Runtime PNGs are deterministically processed by `tools/pixel_art_postprocess.gd` into the registered 16-color palette with binary alpha. `make validate` rejects a runtime cell that exceeds this palette or reintroduces semi-transparent antialiasing.

## Animation and icon expansion

`emberwood_animation_atlas.png` is an 8x8 atlas of 64px cells. Rows 0-3 are hero south/west/east/north; columns are idle A/B, move A/B, attack A/B, hit, death. Rows 4-6 use the same columns for Slime, Forest Ranger, and elite Forest Ranger. Row 7 is tree A/B, stone A/B, workbench A/B, and lumber mill A/B.

`emberwood_item_icons.png` is a 4x4 atlas of 64px cells:

| Row | Column 0 | Column 1 | Column 2 | Column 3 |
|---|---|---|---|---|
| 0 | sword | bow | wand | helmet |
| 1 | body armor | boots | ring | amulet |
| 2 | wood | stone | moonleaf | plank |
| 3 | salvage scrap | island shard | fallback satchel | empty slot |

Both runtime atlases are rebuilt from their alpha source masters by `tools/pixel_art_postprocess.gd`, then quantized with the same palette/binary-alpha contract as the original family.

## v3 visual-polish expansion

Emberwood v3 is the active production presentation. It keeps the 64px semantic-cell contract and adds these versioned atlases without deleting the v2 rollback assets:

| Runtime atlas | Grid | Responsibility |
|---|---:|---|
| `emberwood_hero_v3_atlas.png` | 8x8 | Directional hero idle/move/attack/hit/death poses. |
| `emberwood_actors_v3_atlas.png` | 8x8 | Slime, normal/elite Ranger, and Abyssal Warden animation poses. |
| `emberwood_resources_v3_atlas.png` | 4x4 | Tree, stone, Moonleaf damage states and world-resource pickups. |
| `emberwood_structures_v3_atlas.png` | 4x4 | Workbench, mill, collector, storage, Tidecatcher, pedestal, rift, event, chest. |
| `emberwood_item_icons_v3.png` | 8x8 | Sixty-four equipment, resource, rarity, shard, kit, status, empty, and fallback icons. |
| `emberwood_vfx_v3_atlas.png` | 7x8 | Seven-frame hit, critical, gather, death, pickup, Legendary, materialize, and rift effects. |
| `emberwood_terrain_v3.png` | 4x4 | Forest grass, path topology, transitions, and special biome ground. |
| `emberwood_living_world_v1_atlas.png` | 4x4 | Moonleaf Thicket, Tidewell, Whispering Shrine, and Firefly Hollow ready/active/cooldown states. |

`VisualAssetLibrary` owns actor/resource/structure/VFX/terrain coordinates. `ItemIconLibrary` owns item semantics. Generated masters are provenance inputs only; `tools/pixel_art_postprocess.gd` slices, resizes, quantizes, and enforces binary alpha before runtime import. The exact prompt set, source paths, checks, and visual review are recorded in `evidence/2026-08-18-emberwood-v3-visual-polish.md`.

`forest_tiles.png` is the 128x64 runtime terrain derivative: seamless 64px grass and dirt cells using the registered Emberwood palette. It removes source-cell isolation padding so gameplay terrain has no grid seams. Deterministic scene decoration adds non-colliding leaf or stone accents to roughly 10-15% of grass cells rather than stamping a prop into every tile.

## v4 starting-island plate

`emberwood_starting_island_v4.png` is the active 1792x1152 full-map ground plate beneath the starting-island scene. It composes four readable ground regions, path hierarchy, wet lowland, ancient-root traces, rocky rise, and shoreline into one original image while leaving every solid or interactive object in its existing scene node. The runtime image is globally quantized to 128 opaque colors and upscaled with nearest-neighbor filtering. `StartingIslandTerrain` owns its approximate shoreline collision; the plate itself never defines collisions or rewards. Source, full prompt, deterministic post-processing, numeric checks, and 1280x800 review are recorded in `evidence/2026-08-18-island-story-starting-terrain.md`.

## Forest Warden v1

`emberwood_forest_warden_v1_atlas.png` is the Forest installed-island climax atlas. Its exact 4x4 grid provides four idle, four walk, four root-staff attack, two hit, and two death frames. The runtime sheet is rebuilt from `source/emberwood_forest_warden_v1_master_alpha.png` by `tools/forest_warden_asset_builder.gd`, which normalizes the source grid to 64px cells, applies the registered sixteen-color Emberwood palette, and enforces binary alpha. `VisualAssetLibrary.forest_warden_texture` is the only runtime coordinate owner. Full prompt, provenance, mechanic mapping, and captures are recorded in `evidence/2026-08-18-forest-warden-encounter.md`.

## Generation provenance

- Tool: OpenAI built-in image generation (imagegen skill), 2026-08-10.
- Workflow: generated on a flat `#ff00ff` chroma background, background removed with the standard `remove_chroma_key.py` helper, cropped to an exact 4x4 grid.
- Prompt summary: cohesive top-down three-quarter pixel-art atlas; teal/gold hero; forest Slime and Ranger; tree, stump, stone and drops; grass/path tiles; hit and Legendary plant VFX; upper-left light; controlled Emberwood palette; strict isolated 4x4 composition; no text, logos, gradients, antialiasing, or watermark.
- Full final prompt is recorded in `evidence/2026-08-10-tasks-31-45-visual-foundation.md`.

The v2 animation and icon prompts, generated source paths, processing commands, and visual review are recorded in `evidence/2026-08-10-tasks-46-60-animation-world-loot.md`.

The living-world atlas prompt, chroma/alpha masters, semantic cell map, deterministic atlas-bleed cleanup, gameplay contracts, and 1280x800 captures are recorded in `evidence/2026-08-18-living-world-animation-polish.md`.

The source master is provenance material and excluded from Godot import/export by `source/.gdignore` and export filters. Do not add unrelated art families to production scenes to fill gaps.
