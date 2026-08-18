# Living World And Animation Polish

Status: implementation complete — physical controller/Steam Deck feel review pending

## Goal

Remove the two reported visual artifacts, improve presentation smoothness without changing authoritative timing, and make the starting island feel inhabited through a small set of controller-accessible interactive world props.

## Assumptions and scope

- The line over the hero is the unconditional procedural weapon line in `player.gd`; an unarmed hero must have no persistent line.
- The plus-shaped zones are empty island-slot markers; they will become authored Emberwood pedestals while keeping their existing installation behavior.
- Pixel-art smoothness comes from better animation cadence, eased secondary motion, anticipation, and recovery—not texture filtering or subpixel blur.
- New world density must be functional. Each new prop has an interaction, readable state change, bounded reward/effect, and cooldown.
- Gameplay rules remain deterministic and presentation never owns hit, movement, reward, or cooldown authority.

## Acceptance criteria

- No persistent line is drawn over the player; attack tells appear only during active attacks.
- Empty and installed island slots use authored pedestal states and no plus glyph.
- Hero, common enemies, resources, buildings, island pedestals, and living-world props use bounded eased secondary animation while authoritative transforms remain unchanged.
- The starting island contains at least four distinct interactive prop types and seven total props: Moonleaf thicket, Tidewell, Whispering shrine, and Firefly hollow.
- Props expose controller interaction labels, visible ready/active/cooldown states, and real effects: resource reward, healing, resource cache, or bounded guardian challenge.
- Cooldowns prevent repeated reward spam, guardian population is capped, and no prop performs per-frame logging or world scans.
- New raster art is project-original, 64px-cell pixel art with nearest filtering, binary alpha, and the registered Emberwood palette.
- The result is readable at 1280x800 and passes repository validation.

## Tests defined before implementation

- Unit: living-world definitions validate, cooldowns/rewards are positive and effect IDs are supported; presentation easing is deterministic and bounded.
- Integration: the world contains the expected prop set; interaction uses existing controller-facing contracts; repeat interaction during cooldown cannot duplicate rewards; healing and guardian caps work; island slots use sprite pedestals and no plus marker.
- Simulation: a fixed route repeatedly activates props and advances cooldowns without unbounded spawned entities or nondeterministic inventory totals.
- Visual: capture the starting route, island pedestal, all prop states, and a dense combat interaction at 1280x800.
- Build: `static-validate`, full `validate`, Windows export, and exported executable smoke.

## Work sequence

- [x] Inspect reported artifacts and record acceptance criteria/tests.
- [x] Generate, post-process, import, and register the living-world atlas.
- [x] Replace procedural hero/slot artifacts and improve secondary animation cadence.
- [x] Implement living-world rules, prop scene behavior, world effects, and deterministic placement.
- [x] Add unit, integration, simulation, and visual coverage.
- [x] Validate, export, capture evidence, inspect the diff, and document limitations.

## Risks and rollback

- Extra props can make combat noisy. Keep silhouettes low, interaction prompts targeted, and total prop count fixed.
- Rewards can become an exploit. Apply cooldowns before effect dispatch and cap active guardians/cache output.
- Smoother motion can blur pixel art. Keep nearest filtering and visual offsets bounded; never smooth the authoritative body.
- Generated atlas cells may be ambiguous. Semantic lookup isolates replacement to one atlas row/cell mapping.
