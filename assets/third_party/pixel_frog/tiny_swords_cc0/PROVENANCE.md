# Tiny Swords CC0 terrain and actor provenance

- Author: Pixel Frog
- Work: Tiny Swords, Update 010 (separately distributed CC0 edition)
- Upstream project page: https://pixelfrog-assets.itch.io/tiny-swords
- Retrieved from: https://github.com/FulAppiOS/Agent-Quest/tree/main/client/public/assets/themes/tiny-swords-cc0
- Retrieved revision: `010c791207c9e5670f07d0fbca3a62f3d1eb0fa7`
- Retrieved on: 2026-08-18
- License: CC0 1.0 Universal; the exact supplied text is retained in `LICENSE.txt`.
- Runtime files: `tilemap_flat.png`, copied byte-for-byte from `Terrain/Ground/Tilemap_Flat.png`; `terrain_deco_atlas.png`, a project-built atlas from selected `Deco/*.png`; `hero_animation_atlas.png` and `enemy_animation_atlas.png`, project-built actor atlases from selected Pawn, Warrior, Archer, TNT Goblin, and Torch Goblin sheets.
- Use in Shardbound Isles: 64px grass/path terrain, bounded background decorations, equipment-aware Blue/Purple hero variants, Red TNT Goblin chaser, Red/Purple Archer enemies, and Purple Torch Goblin boss.
- Selected actor sources: `Pawn/Blue/Pawn_Blue.png`, `Pawn/Purple/Pawn_Purple.png`, `Warrior/Blue/Warrior_Blue.png`, `Archer/Blue/Archer_Blue.png`, `Archer/Red/Archer_Red.png`, `Archer/Purple/Archer_Purlple.png`, `Goblins/Troops/TNT/Red/TNT_Red.png`, and `Goblins/Troops/Torch/Purple/Torch_Purple.png`.
- Modifications: actor sheets are sliced on exact 192px cells, selected into six-frame semantic clips, resized nearest-neighbor to 128px runtime cells, and thresholded to binary alpha. No interpolation, painted edits, or cross-frame sampling is applied. Blue Pawn is the unarmed/gathering silhouette, Blue Warrior is melee, Blue Archer is ranged, and Purple Pawn is the arcane silhouette. Unarmed and arcane attacks retain clean body clips while damage feedback remains in gameplay VFX, avoiding mismatched hidden-tool arcs. The Archer move clip intentionally uses its authored second idle row because the CC0 edition has no dedicated Archer walk row. Selected originals are retained under the ignored `source/` directory.
- Attribution: not required by CC0; retained here as project provenance.
- Replacement risk: medium. The terrain establishes the ground palette and path silhouettes, but authoritative gameplay uses coordinates and collision rather than atlas regions.

The current free edition on the upstream itch page has different redistribution wording. This repository therefore relies specifically on the separately labelled CC0 edition and preserves its supplied license, rather than assuming the current edition's terms apply.
