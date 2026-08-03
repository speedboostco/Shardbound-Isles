# M2 — Diablo-like Loot

## Goal

Implement every repository-side criterion in `evidence/M2.txt`: three behaviorally distinct controller weapons, deterministic rarity/affix/item generation, typed multi-slot equipment and derived stats, controller-readable comparison/salvage UI, modular legendary behaviors, and bounded world loot.

## Compatibility assumptions

- Preserve the M1 seed `424242`, stable item identity, legacy `power`/`archetype` keys, and schema-1-to-3 save migration while advancing current saves to schema 4.
- Canonical weapon archetypes are `sword`, `bow`, and `wand`; legacy combat families remain `melee`, `ranged`, and `magic` compatibility fields.
- Equipment slots are `weapon`, `helmet`, `body`, `boots`, `ring`, and `amulet`. Equipping replaces only the matching slot and never destroys the prior item.
- Stats are recalculated from immutable base values on every equipment change: `(base + sum(additive)) * product(1 + multiplicative)`.
- Ordinary affixes and legendary behaviors are separate. A legendary behavior never consumes an ordinary affix slot.
- Loot filtering is policy architecture only in M2; automatic salvage is configurable but disabled by default.
- Ground equipment is capped by evicting oldest low-importance non-legendary drops. Legendary drops are protected and explicitly signaled if pressure prevents cleanup.
- Existing post-M1 boss, rift, island, crafting, automation, and save flows remain operational.

## Acceptance tests defined before implementation

- Unit: base registry contains sword/bow/wand with distinct attack profiles and shared data shape.
- Unit: rarity weights and affix-count contracts; fixed-seed statistical distribution; overlap proves rarity is not a strict power ordering.
- Unit: at least 12 ordinary affixes cover all six categories with stable IDs, ranges, weights, tags, eligibility, conflicts, and definition validation.
- Unit: full fixed-seed generation repeats, survives 10,000 items, produces no duplicate/conflicting/ineligible affixes, and JSON round trips.
- Unit: six typed equipment slots, correct replacement/removal, stat order, no repeated-equip accumulation, favorite/equipped salvage protection, and level/rarity salvage values.
- Unit: modular legendary registry, attack/kill/resource events, clean activation/deactivation, chain limits/cooldown/recursion guard, safe smelter fallback, living-arrow cap/expiry, and stress coverage.
- Integration: sword/bow/wand resolve different target shapes through the shared attack path; legendary effects attach/detach; 200 ordinary drops remain bounded while legendary presentation is protected.
- Integration/UI: controller selection exposes base stats, ordinary affixes, legendary effect, signed stat differences, quick equip/keep/salvage actions, and favorite protection at 1280x800.
- Simulation: fixed M2 seeds generate/equip/salvage a mixed loadout, trigger all three new legendary behaviors, and report deterministic metrics.

## Implementation sequence

- [x] Read M2 and system-of-record documents; define compatibility and tests.
- [x] Add red pure-domain tests.
- [x] Implement base, rarity, affix, generation, equipment, stats, salvage, and filter rules.
- [x] Implement weapon attack profiles and modular legendary behavior components.
- [x] Integrate world loot limits, effects, multi-slot save state, and controller UI.
- [x] Add deterministic simulation, stress/performance evidence, and 1280x800 visual capture.
- [x] Run targeted and full validation, exports, diff review, and update documentation/evidence.

## Outcome

Completed on 2026-08-03. Full validation passed with 21 static checks and 465 assertions. Windows and Linux exports succeeded; the Windows artifact also passed a headless launch smoke test. Acceptance mapping, deterministic metrics, visual review, hashes, and limitations are recorded in `evidence/2026-08-03-m2-diablo-loot.md`.
