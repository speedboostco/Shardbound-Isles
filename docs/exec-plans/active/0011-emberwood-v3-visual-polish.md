# Emberwood v3 Visual Polish

Status: implementation complete — physical controller/Steam Deck feel review pending

## Goal

Replace the remaining bootstrap-looking presentation with one coherent, project-original Emberwood v3 family. The pass improves animation cadence and silhouettes, expands world/loot/VFX coverage, and keeps authoritative gameplay, collision, saves, and deterministic rules unchanged.

## Assumptions and scope

- “Highest quality” means the strongest coherent project-original variant that remains readable as crisp pixel art at the 1280x800 gameplay scale. It does not mean mixing unrelated third-party packs or scaling blurry source art into the game.
- Existing Emberwood v2 art is the style reference. New AI-assisted source masters are versioned siblings; v2 remains available for rollback until v3 passes validation.
- Runtime atlases keep 64x64 integer cells, nearest filtering, binary alpha, the registered palette, and dimensions at or below 2048x2048.
- Animation is presentation-only. It may observe movement, attacks, hits, damage stages, and death, but never changes gameplay timing or results.
- Automated focus checks and 1280x800 captures are repository evidence. Physical Steam Deck/controller feel remains a human gate and will not be inferred.

## Acceptance criteria

- Hero, Slime, Forest Ranger, elite Ranger, resources, buildings, pickups, portal/event props, boss, and core VFX use one visually coherent Emberwood v3 family or an intentionally retained semantic v2 fallback.
- Hero and normal enemies use 4-frame idle/locomotion plus 3-6 frame attacks and authored hit/death poses without moving authoritative bodies.
- Terrain and props add depth and variation without obscuring collision, interaction targets, enemies, or loot.
- Ordinary, Rare, Epic, Legendary, shard, resource, and equipment rewards remain distinguishable by shape and presentation, not hue alone.
- Effects have bounded lifetimes/counts and reduced-effects behavior. No animation or VFX adds per-frame logging or authoritative state.
- Every runtime raster imports losslessly with nearest filtering, no mipmaps, binary alpha, and no more than 16 opaque colors per 64px cell.
- Reference scenes remain readable, unclipped, and correctly layered at 1280x800.

## Tests defined before implementation

- Unit: v3 atlas dimensions and semantic coordinates; animation frame counts/state mapping; missing semantic IDs use an explicit fallback.
- Integration: hero/enemy/resource/building states resolve v3 textures; attacks still emit exactly once; hit/death presentation does not alter authority; important world props render without changing interaction contracts.
- Simulation: fixed-seed dense combat/loot route keeps bounded VFX and deterministic gameplay metrics.
- Visual: deterministic 1280x800 captures for exploration/combat, equipment/loot, island/world transformation, and boss/VFX stress.
- Build: `static-validate`, full `validate`, Windows export, and exported executable smoke.

## Work sequence

- [x] Record baseline and generate the v3 hero, actor/world, environment, item, terrain, and VFX source masters.
- [x] Deterministically remove chroma, slice to 64px cells, quantize to the Emberwood palette, and validate import metadata.
- [x] Extend semantic asset lookup and shared animation clip metadata; migrate presentation consumers without changing gameplay rules.
- [x] Polish terrain/prop layering, pickups, boss, portal/event, island, and bounded VFX presentation.
- [x] Add automated contracts, update the Art Bible/family manifest/asset register, and record exact generation prompts.
- [x] Run repository validation/export, capture visual evidence at 1280x800, inspect the diff, and record limitations.

## Risks and rollback

- Generated grids may contain ambiguous cells. Reject or regenerate unclear masters before runtime use; semantic lookup keeps replacement local.
- More animation frames can desynchronize with attacks. Existing gameplay events remain authoritative and tests assert one attack emission.
- Denser art can reduce combat readability. Keep decoration non-colliding/sparse, preserve silhouettes, and inspect dense fixed-seed captures.
- Runtime cost can grow with VFX. Keep texture atlases shared, effects self-cleaning, and effect counts bounded.
