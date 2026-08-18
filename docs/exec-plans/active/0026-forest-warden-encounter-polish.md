# Forest Warden Encounter Polish

## Goal

Turn the first installed-island climax into a distinct, readable Forest Warden encounter with bespoke presentation, deterministic combat phases, reactive Tala guidance, and synchronized event audio.

## Assumptions

- This is one customer-facing vertical slice, not a claim that every biome already has bespoke boss production values.
- The Forest Warden may keep the existing `CharacterBody2D`, health, projectile, and quest-completion contracts, but must not inherit the ordinary Ranger's three-arrow behavior or visual atlas.
- Audio is generated locally as deterministic authored waveform data and remains fully offline; it has no gameplay authority.
- Physical-controller feel cannot be certified without hardware, so automated controller routing and a reproducible capture are the repository gate.

## Acceptance criteria

- A versioned original Forest Warden atlas supplies idle, walk, root-slam windup/impact, hit, and death frames; no Ranger texture is used for the Forest Warden.
- The encounter alternates deterministic aimed thorn volleys and a root eruption. Root eruption exposes a minimum 0.75-second telegraph, a bounded danger lane, and safe side space before damage.
- Phase two begins below half health and changes cadence/pressure without only increasing health.
- Telegraph visuals contain no full white circle around the player or Warden.
- Tala introduces the mechanic, reacts to phase two, and confirms the choice outcome through short event-driven lines that do not repeat every frame.
- Windup, impact, phase transition, hit, and defeat have distinct bounded audio cues synchronized to combat signals.
- Warden-created projectiles/zones/audio nodes clean up on defeat and island removal.
- Controller-only story progression remains focus-safe at 1280x800.
- Save schema remains 11 because the encounter contains no new persistent mid-fight authority.
- Unit, integration, full validation, Windows export, exported-build smoke, and visual evidence pass.

## Test-first plan

- Unit-test attack selection, telegraph durations, phase thresholds, thorn angles, root-lane geometry, damage windows, and deterministic sequencing.
- Integration-test unique atlas usage, attack telegraph/resolve, safe-vs-danger lane damage, phase transition/Tala line, audio events, death cleanup, and story completion.
- Capture the Forest Warden windup and phase-two root eruption at 1280x800.

## Status

Complete on 2026-08-18.

## Evidence

- Test-first reproduction failed with the missing `ForestWardenPattern`; the completed unit suite passes 693 assertions.
- Targeted integration passes 524 assertions, including 28 Forest Warden encounter assertions.
- Full `tools/dev.ps1 validate`: import passed, 26 static checks passed, 1,312 assertions passed, 0 failures; JUnit written to `build/test-results/all.xml`.
- `evidence/forest-warden-windup-1280x800.png` and `evidence/forest-warden-root-eruption-1280x800.png` were captured at 1280x800 and manually inspected after removing the rejected circular overlays.
- Windows debug export succeeded and includes `emberwood_forest_warden_v1_atlas.png`; the exported executable completed a three-frame headless startup smoke with exit code 0.
- `git diff --check` passed.
