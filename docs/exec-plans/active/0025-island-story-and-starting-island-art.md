# Island Story and Starting-Island Art Pass

## Goal

Deliver one authored-feeling island story chain that connects installed-world loot, a resident, player choice, biome events, combat, rewards, and a persistent Expedition Mark shop, while replacing the flat starting-island floor with a coherent premium terrain composition.

## Research-derived visual principles

- Use authored composition over uncurated procedural scatter: Enshrouded describes procedural tools followed by deliberate hand-authored world design.
- Give every region a material history and culture kit: Diablo IV's environment-art breakdown connects weather, props, interactives, and local history.
- Reserve the strongest detail and contrast for paths, landmarks, interactables, and combat readability rather than covering every cell equally.
- Make the environment react through bounded events, props, weather, and sound without adding per-frame simulation to static terrain.

References:

- https://enshrouded.com/en-US/FAQ
- https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022
- https://news.blizzard.com/en-us/article/23964183/peeling-back-the-varnish-the-graphics-of-diablo-iv
- https://press.stunlock.com/v-rising-a-new-game-from-stunlock-studios/

## Acceptance criteria

- Installing a valid island materializes Tala the Shard Warden and a deterministic story definition tied to the island's stable ID, slot, seed, biome, and level.
- The chain has offer, survey, explicit restoration-or-purge choice, biome-specific action, special-Warden combat, completion, and claim states.
- Stable event tokens prevent duplicate progress and reward callbacks.
- Restoration and purge produce different final loot while both unlock Tala's Expedition Mark exchange.
- The exchange exposes at least three useful offers and validates cost before mutation; purchases use existing equipment, shard, and resource pickup pipelines.
- Removing or replacing the installed island clears its resident, events, and special enemy without leaving scene references; reinstalling the same shard can resume serialized state.
- Controller focus is trapped inside the story/exchange panel and every action is available without mouse or text input.
- Save schema 11 persists the story state and safely migrates schema 10.
- The starting island uses one original 1792x1152 ground plate with four readable regions, organic routes, ocean edge, no plus/cross markers, and explicit shore collision.
- Existing interactive props, collision landmarks, actors, and pickups remain more salient than background detail at 1280x800.
- Unit, integration, full validation, Windows export, exported-build smoke, and visual capture pass.

## Test-first plan

- Unit-test deterministic biome definitions, every transition, branch separation, token deduplication, claim idempotency, vendor plans, serialization, and invalid-state rejection.
- Integration-test installation, Tala interaction/focus, survey events, branch choice, biome events, special enemy, reward collection, shop purchase, save/load, and island cleanup.
- Capture the renewed starting island and the installed-island story decision at 1280x800.

## Status

Complete on 2026-08-18.

## Evidence

- `make validate` equivalent (`tools/dev.ps1 validate`): import passed, 26 static checks passed, 1,259 assertions passed, 0 failures; JUnit written to `build/test-results/all.xml`.
- Targeted integration: 496 assertions, 0 failures.
- Visual capture: `evidence/starting-island-v4-1280x800.png` and `evidence/island-story-choice-1280x800.png`, both 1280x800 and manually inspected for readability, focus, containment, layering, and missing assets.
- Windows debug export: `build/windows/ShardboundIsles.exe` and `.pck` produced successfully; the exported executable completed a headless three-frame startup smoke with exit code 0.
- `git diff --check`: passed.
