# Island Story and Starting-Terrain Evidence — 2026-08-18

## Outcome under test

- Emberwood uses one original 1792x1152 composed ground plate with four readable regions, organic routes, water edge, and no plus/cross terrain markers.
- The ground plate remains presentation-only; `StartingIslandTerrain` provides a separate explicit shoreline collision and existing scene nodes retain interaction/collision authority.
- Installing an island creates Tala and a persistent deterministic island story: survey, informed restoration/purge branch, biome action, special Warden, visible reward, and a three-offer Expedition Mark exchange.

## Visual inspiration translated into rules

- Blizzard's Diablo IV environment-art material treats location history, materials, lighting, props, and interactives as one readable environmental narrative. Emberwood therefore uses visibly different root-grove, meadow/wetland, camp-route, and rocky-rise ground languages rather than homogeneous texture scatter.
- Blizzard's graphics material emphasizes blended terrain and restrained interactive emission without sacrificing gameplay; the plate keeps the route/central clearing brightest while props, pickups, and combatants remain separate higher-salience objects.
- Enshrouded describes procedural assistance followed by deliberate hand-authored world work and later added landscape variety/verticality to reward exploration. The new plate is one curated composition, not a repeated tile/noise pass, and its four regions provide distinct destinations.
- V Rising's published loop connects exploration, survival, building, and rising power. Tala's installed-island story turns the visual destination into a progression decision and persistent reward sink instead of decoration alone.

References:

- https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022
- https://news.blizzard.com/en-us/article/23964183/peeling-back-the-varnish-the-graphics-of-diablo-iv
- https://enshrouded.com/en-US/FAQ
- https://enshrouded.com/en-US/news/enshrouded-thralls-of-twilight-update
- https://press.stunlock.com/v-rising-a-new-game-from-stunlock-studios/

## Generated asset provenance

- Tool/mode: OpenAI built-in image generation through the `imagegen` skill.
- Generated master: `C:/Users/vserg/.codex/generated_images/019fc699-8a42-71e2-8311-8cd67ee7113c/exec-a2459d1f-d4ab-4e09-aaea-65222abd6ea5.png` (1586x992).
- Preserved source master: `assets/original/emberwood/source/emberwood_starting_island_v4_master.png` (excluded from import/export by `source/.gdignore`).
- Runtime asset: `assets/original/emberwood/emberwood_starting_island_v4.png` (1792x1152, RGB, 128 opaque colors).
- Deterministic post-process: resize to logical 896x576 with LANCZOS, globally quantize to 128 colors without dithering, convert to RGB, then upscale 2x with nearest-neighbor.

### Final generation prompt

> Use case: stylized-concept
>
> Asset type: production game terrain background plate for a 2D top-down action-survival RPG
>
> Primary request: create an original premium hand-painted pixel-art ground plate for a lush enchanted starting island called Emberwood, designed to sit beneath separate interactive sprites and collision objects
>
> Scene/backdrop: a large coherent grassy island surrounded at the outer border by deep teal ocean; a warm ochre footpath crosses the island and branches naturally toward four readable regions: a sheltered central camp clearing, an ancient western grove, a cool violet moonleaf meadow in the southwest, and a rocky sunlit rise in the east; include shallow puddles, eroded soil, moss, small fallen leaves, pebble clusters, tree-root traces, shoreline foam, and subtle ground flowers
>
> Style/medium: polished modern 16-bit-inspired pixel art with hand-painted clusters, restrained texture, crisp shapes, coherent scale, no anti-aliased painterly blur; original visual language; attractive at a top-down gameplay camera
>
> Composition/framing: wide orthographic top-down map plate, approximately 16:10; continuous traversable land, generous clear combat pockets and readable paths; strongest landmark is the central warm clearing, secondary landmarks at each region; edges irregular and organic
>
> Lighting/mood: warm adventurous late-morning light, gentle ambient occlusion painted into ground details, inviting safety near center and mysterious depth toward edges
>
> Color palette: moss green, fern green, muted olive, warm ochre, slate gray, moonleaf violet accents, deep teal water; controlled contrast so characters and pickups remain more salient
>
> Materials/textures: layered grass tufts, packed earth, worn stone, moss, water ripples and shoreline foam, all as ground-level detail only
>
> Constraints: no characters, no creatures, no buildings, no trees, no bushes, no boulders, no chests, no loot, no UI, no words, no symbols, no plus signs, no crosses, no grids, no tile seams, no logos, no trademarks, no watermark; do not imitate any specific commercial game; all visible elements must read as flat ground decoration and must not imply collision; keep routes and combat spaces highly readable

## Reproducible visual artifacts

- `evidence/starting-island-v4-1280x800.png`: normal play at the reference viewport. The central route, root-grove traces, wet ground, rocky path, interaction props, player/NPC silhouettes, bounded HUD, and absence of plus markers are visible together.
- `evidence/island-story-choice-1280x800.png`: controller branch modal over the installed island. Both branches and their distinct reward classes are visible before commitment; the panel, focus outline, footer, and background shoreline remain in frame.

Capture command:

```powershell
$env:LOCALAPPDATA='C:\ceer\Shardbound-Isles\.godot-user\local'
$env:APPDATA='C:\ceer\Shardbound-Isles\.godot-user\roaming'
& $env:GODOT_BIN --path 'C:\ceer\Shardbound-Isles' --resolution 1280x800 --script res://game/tests/visual/capture_island_story_terrain.gd
```

## Automated coverage

- `island_story_quest_test.gd`: 34 assertions over deterministic definitions, six biomes, transitions, branches, stable-event deduplication, rewards, offers, and restore validation.
- `island_story_flow_test.gd`: 34 assertions over physical installation/Tala/sites/Warden, controller focus, reward pickup, Mark exchange, save/load, migration, and island cleanup.
- `art_asset_validator.gd`: dimensions/import/source isolation and the explicit 128-color terrain-plate ceiling.

## Visual review

At 1280x800, the ground reads as one island rather than repeated tiles. Detail density is concentrated away from the warm main route and center, so actors and interactive silhouettes remain identifiable. Both story actions are fully visible and the destructive/exploitative tradeoff is stated before selection. The shoreline collision follows a deliberately simplified polygon rather than deriving physics from pixels.
