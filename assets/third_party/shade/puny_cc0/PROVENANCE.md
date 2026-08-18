# Shade Puny CC0 provenance

- Author: Shade (`merchant-shade`)
- Character work: Puny Characters, including the later Orc/Human update
- Official listing: https://opengameart.org/content/puny-characters
- World work: Free 16x16 Puny World Tileset
- Official listing: https://merchant-shade.itch.io/16x16-puny-world
- Retrieved: 2026-08-18 from the official OpenGameArt attachment and official itch.io download flow
- License: Creative Commons Zero 1.0 Universal on both source listings; commercial use and modification are explicitly allowed and attribution is not required
- AI disclosure: the Puny World listing states that no generative AI was used
- Runtime files: `puny_hero.png` (Warrior Blue), `puny_orc.png` (Orc Grunt), `puny_archer.png` (Archer Purple), `puny_mage.png` (Mage Red), `puny_tree.png`, `puny_world.png`, and project-authored `puny_boulder.png`, `puny_flora_1.png`, and `puny_flora_2.png`
- Source retention: exact downloaded PNG/Tiled sources live below ignored `source/`; raw download containers and temporary web pages are not retained
- Transform: `tools/puny_asset_builder.gd` reproducibly maps opaque source pixels to the nearest registered 16-color Emberwood/Puny palette value and thresholds alpha to binary. The same builder draws the small boulder and two transparent flora details from reviewed fixed pixel masks using only that palette. Godot then crops 32px actor cells and 16px terrain/object cells and scales them with nearest filtering; no actor frame is generated, mirrored, or interpolated
- Animation layout: actor rows are the eight authored directions. Columns are idle 0–1, walk 2–3, sword 4–7, bow 8–11, staff 12–15, throw 16–17, hurt 18, and death 19–23
- Use: one protagonist body with equipment-specific actions; Orc melee enemies; Archer/Mage ranged, elite, and boss silhouettes; grass/path terrain; tree, boulder, herb, and decorative details
- Replacement risk: low for licensing and animation coverage, medium for subjective scale acceptance at 1280×800
