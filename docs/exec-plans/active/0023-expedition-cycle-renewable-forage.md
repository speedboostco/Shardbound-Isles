# Expedition Cycle and Renewable Forage

## Goal

Turn survival preparation into a changing expedition context through deterministic time, biome weather, shelter benefits, and renewable persisted forage without hunger, thirst, or passive damage.

## Acceptance criteria

- A seeded 240-second day has deterministic dawn, day, dusk, and night phases.
- Weather is deterministic per world seed, day index, and installed biome; supported weather has a visible gameplay effect.
- Night increases enemy pressure and gathering opportunity together rather than only inflating health.
- Resting at the field camp grants 90 seconds of shelter: +2 mana regeneration and one point of damage reduction.
- Shelter expires safely and never becomes a mandatory survival meter.
- Rain/Fog/Gale provide distinct forage/resource opportunities; the current effect is visible in the expedition status.
- Fiber and Emberberry nodes regrow after authored delays without duplicating depletion rewards.
- Renewable node availability and remaining regrow time persist through save schema 9.
- Expedition time, seed, weather derivation, and shelter time persist through schema 9.
- HUD status is legible at 1280x800 and controller menus remain unclipped.

## Test-first plan

- Unit-test phase boundaries, clock/day wrapping, seeded weather repeatability/separation, shelter expiry, effect bundles, renewable depletion/regrowth, and restore rejection.
- Integration-test camp shelter, mana/damage effects, weather gathering, node regrowth, HUD status, and schema-9 round-trip.
- Run full validation, refresh 1280x800 evidence, export Windows, and smoke-launch the exported executable.

## Status

Implemented. Unit and integration acceptance are automated; final full validation, visual review, and Windows export evidence are recorded in the implementation report.
