# Emberwood Bootstrap v1

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

`forest_tiles.png` is the 128x64 runtime terrain derivative: seamless 64px grass and dirt cells using the registered Emberwood palette. It removes source-cell isolation padding so gameplay terrain has no grid seams. Deterministic scene decoration adds non-colliding leaf or stone accents to roughly 10-15% of grass cells rather than stamping a prop into every tile.

## Generation provenance

- Tool: OpenAI built-in image generation (imagegen skill), 2026-08-10.
- Workflow: generated on a flat `#ff00ff` chroma background, background removed with the standard `remove_chroma_key.py` helper, cropped to an exact 4x4 grid.
- Prompt summary: cohesive top-down three-quarter pixel-art atlas; teal/gold hero; forest Slime and Ranger; tree, stump, stone and drops; grass/path tiles; hit and Legendary plant VFX; upper-left light; controlled Emberwood palette; strict isolated 4x4 composition; no text, logos, gradients, antialiasing, or watermark.
- Full final prompt is recorded in `evidence/2026-08-10-tasks-31-45-visual-foundation.md`.

The source master is provenance material and excluded from Godot import/export by `source/.gdignore` and export filters. Do not add unrelated art families to production scenes to fill gaps.
