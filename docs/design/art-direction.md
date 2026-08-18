# Art Direction

This document is the single source of truth for in-game visual implementation. Marketing art and concept exploration may diverge, but production assets and scenes must satisfy these measurable rules.

## View, grid, and scale

- Gameplay uses a top-down three-quarter view: horizontal surfaces are visible, vertical forms rise toward screen-up, and characters never use side-view platformer perspective.
- The authored logical tile is 64x64 pixels. Terrain may come from a larger source cell, but it is rendered into exact 64-pixel world rectangles with nearest filtering.
- Ordinary characters occupy 40-64 rendered pixels in height; the hero target is 56 pixels, normal enemies 44-56, elites 56-72, and bosses 80-112.
- Resource silhouettes are 64-112 pixels high. Their collision remains a separate gameplay shape and must not be inferred from opaque pixels.
- Gameplay sprites use integer destination positions after camera projection where practical. Project-wide 2D transform and vertex snapping is enabled and camera follow smoothing is disabled; authoritative gameplay transforms remain continuous and are never rounded by animation code. Presentation bob or recoil may use half-pixels only while stationary.
- The reference viewport is 1280x800. HUD body text is at least 16 px, normal interactive text 18 px, headings 22-30 px, and controller targets at least 44 px high.

## Pixel, outline, light, and shadow

- Pixel textures use nearest filtering, no mipmaps, lossless compression, no repeat unless a terrain renderer explicitly tiles a region, and no imported smoothing.
- Sprite edges use one source-pixel-equivalent dark ink outline (`#172331`); inner material boundaries may use the same ink at 50-75% of outer thickness.
- Key light comes from upper-left at roughly 315 degrees. Lit planes are one palette step brighter; cast/contact shadows fall down-right.
- Character and prop contact shadows are compact ellipses no wider than 80% of the silhouette and no taller than 20%; opacity is 20-35%. VFX do not cast world shadows.
- Avoid free gradients in pixel assets. A maximum of four value steps per material is the normal target; UI panels may use flat translucent fills.

## Controlled palette

The production family is built around ink `#172331`, pine `#214e46`, moss `#4d7a4a`, leaf `#76a85b`, cream `#e8d8a8`, gold `#e5a84b`, ember `#e9674c`, tide cyan `#4db7b3`, and eight registered ramp/accent colors. Every active Puny actor, terrain, and ordinary-object cell uses at most 16 opaque colors and binary alpha. Runtime validation enforces the same ceiling on the hero and enemies; there is no higher-color protagonist exception.

Rarity and VFX may add semantic colors, but meaning must also use shape, label, or intensity: Rare uses a pointed ring, Epic a double diamond, and Legendary a tall beam plus crown/flower emblem. Destructive UI uses the word `DESTROY` plus a warning border; color alone is insufficient.

## Animation conventions

- Repeating gameplay animation normally runs at its authored 7-12 frames per second. The production hero retains two idle, two walk, four sword, four bow, four staff, two throw, one hurt, and five death frames for each of eight authored directions. One-shots are time-normalized to authoritative presentation windows and never change cooldown, hit, damage, movement, or collision timing.
- Frame names are `<actor>_<state>_<direction>_<index>` using `south`, `south_west`, `west`, `north_west`, `north`, `north_east`, `east`, and `south_east`; indices start at `00`.
- Runtime state names are exactly `idle`, `move`, `attack`, `hit`, and `death`. `AnimationStateRules` owns priority (`death > hit > attack > move > idle`) and deterministic frame selection; actors own only elapsed presentation time.
- `PresentationMotion` supplies bounded sine phases and frame-rate-independent response factors for visual-only bob, recoil, and settling. The production hero does not receive procedural squash because authored body motion must retain stable proportions. Presentation may move sprite children, never authoritative bodies or collision shapes.
- Animation may read authoritative state but never owns movement speed, target selection, hit timing, reward emission, death, or cleanup.
- Hero facing resolves deterministically to one of eight 45-degree sectors, while a zero vector preserves the previous facing. Enemy contracts may retain four or one authored directions. This makes the same input sequence produce the same visual state without horizontally mirroring the protagonist.
- Puny source rows run clockwise as `south, south_east, east, north_east, north, north_west, west, south_west`; semantic facing must use the explicit source-row map rather than array position.
- The hero impact response keeps its authored hurt frame legible; small enemy/resource flashes remain 0.08-0.16 seconds. Ordinary attack tells are at least 0.18 seconds when reaction is required; the ranged forest attack tell remains 0.55 seconds.

## Environment and actor rules

- Terrain transitions overlap by one logical pixel in the source or are covered by a border cluster; no background color may show through seams.
- Decorative foliage occupies no more than 18% of walkable screen area in the core arena and never adds collision. The opening arena has 50 deterministic flora details plus 16 deliberate solid tree/boulder blockers; collision-bearing props and decoration are separate nodes or layers.
- Living-world density favors interactive silhouettes over filler: the core arena currently has seven fixed props across four types. Each has ready, active, and cooldown art, a controller prompt, a bounded effect, and no collision or per-frame world scan.
- Large props sort by their visual base, not sprite center. A player behind a canopy is partially occluded but their head/outline must remain readable.
- The protagonist remains the same Puny Warrior in every state and direction. Equipment families select distinct authored throw, sword, bow, and staff actions while the HUD, projectile, and impact provide exact weapon identity. Do not mix a different body or scale per loadout. Enemy roles come from the same Puny family and differ by silhouette before hue: Orc chasers are broad melee bodies, Archers expose a bow, elite casters use a Mage silhouette, and the boss is substantially larger.
- Trees, boulders, gatherable resources, workstations, active Tidecatchers, and committed buildings are solid. They stop a `CharacterBody2D` through explicit physics shapes and never inflict contact damage. Flora tufts and flowers remain non-colliding.
- Tree and stone silhouettes must be identifiable at 50% viewport scale. Damage feedback combines a 3-5 px shake/recoil with a contrasting impact glyph.
- Empty island slots use the authored rune pedestal plus a low-contrast elliptical halo. Plus-sign placement glyphs and other editor-like primitives are not production world art.

## UI and VFX language

- Panels use ink/navy fills at 96-99% opacity, 2 px normal borders, 4 px focus borders, and 6 px corner radii. Interior spacing is 8, 12, 16, 24, or 32 px.
- Focused controls gain both a 4 px cream/gold outline and a `>`/action-label cue when the action is destructive. Disabled controls keep at least 4.5:1 text contrast against their panel.
- Normal hit is a compact four-point star, critical hit an eight-point gold star plus outer ring, death a wider fragment burst, projectile impact a directional wedge, gathering a leaf/stone fleck burst, and pickup a short upward pop.
- Ordinary effects live 0.18-0.45 seconds. Reward/Legendary effects live at most 0.85 seconds. A normal effect radius is 18-42 px, death 36-64, and Legendary 55-96.
- Reduced-effects mode removes secondary rings/fragments, halves screen shake, and caps opacity at 70%, while retaining the primary hit/pickup glyph.
- Inventory icons are 64x64 cells rendered nearest inside 64-72 px controller-readable slots. Equipment, resource, crafting, salvage, shard, biome, kit, status, empty, and fallback identities live in `emberwood_item_icons_v3.png`; item data stores semantic `icon_id` values and UI never switches on item names.
- Item icons use one centered silhouette, binary alpha, no external cast shadow, no text, and at most 16 opaque colors per cell. Missing IDs show the satchel fallback rather than an empty or broken texture.

## Positive and negative examples

| Area | Positive | Violation |
|---|---|---|
| Player | 56-64 px coherent armored hero, complete eight-direction motion, stable root, dark contour, and equipment-specific action. | Different body per loadout, side-view art, clipped fall/action, soft filtering, mirrored armor lighting, or animation moving the collision body. |
| Terrain | 64 px grass/path cells rendered nearest with covered seams and non-colliding flowers under 18% density. | Blurred 48 px tiles scaled arbitrarily, exposed seams, or decorative shrubs blocking the deterministic test route. |
| UI | 18 px button text, 48 px target, 4 px visible focus border, explicit `CONFIRM DESTROY`. | Hover-only focus, 12 px body text, transparent tooltip over combat, or red-only destructive meaning. |
| VFX | 32 px hit star lasting 0.25 s, separate critical ring, self-cleanup, reduced-effects fallback. | Full-screen bloom, effect emitting damage, indefinite particles, or identical normal/critical/death feedback. |

## Files, naming, and import

- Project-original raster assets live in `assets/original/<family>/`; third-party assets, if later approved, live in `assets/third_party/<provider>/<pack>/` with an adjacent provenance file.
- Runtime filenames are lowercase snake_case and include role: `hero_atlas.png`, `forest_tiles.png`, `loot_icons.png`. Source masters live under `source/`, include `.gdignore`, and are excluded from exports.
- The current atlas grid is documented in its family manifest. New atlases must have integer cell dimensions and be no larger than 2048x2048 without a measured reason.
- Every production raster has an asset-register entry before scene use. Raw downloaded/source archives (`.zip`, `.7z`, `.rar`, `.psd`, `.aseprite`) are never release resources.

## Source policy and replacement

Shade's reviewed Puny Characters and Puny World CC0 packs supply the production protagonist, melee/ranged/caster enemies, grass/path terrain, trees, and source flora. A deterministic builder applies one registered 16-color palette and creates the small matching boulder/flora variants. Exact sources and transforms live in the asset register. Signature Legendary effects, island-shard presentation, UI, and marketing art remain custom or project-original targets. AI assistance is allowed for controlled production variants when prompt/source provenance is recorded and the output passes every numeric rule above.

Visually distinctive bootstrap assets are replaceable presentation dependencies: code refers to semantic atlas IDs, never author filenames or gameplay IDs. Replacement must preserve cell contracts or update the manifest, validator, captures, and affected scenes together.
