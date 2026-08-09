# Tasks 16-30 conformance

## Goal

Audit and close every repository-side acceptance criterion in `Shardbound_Isles_Tasks_16-30.docx` while preserving the shipped M1-M4 behavior and save compatibility.

## Gate constraint

The source document requires a real controller-only Steam Deck playtest after Task 20 before Task 21. Tasks 21-30 already existed in the repository before this request, so this pass may validate and repair them but cannot claim the hardware gate passed. A human Steam Deck result remains required.

## Assumptions

- Existing stable `item_id`/`id`, legacy archetype names, and schema-6 saves remain readable; canonical runtime payloads additionally expose `instance_id`.
- `SeededRngStreams`, registries, equipment dictionaries, and the current controller modal remain the established architecture.
- A bow projectile is a short-lived visual/gameplay request with one deterministic resolved hit; the shared attack rules remain authoritative.
- Salvage confirmation is armed for one stable item ID and cleared by selection, panel close, or state refresh after completion.

## Acceptance gaps found

- ITEM-001 lacks executable definition diagnostics and the serialized `instance_id` key.
- WPN-001 resolves the bow at range but has no projectile lifecycle to clean up on weapon changes.
- AFF-001/AFF-002 lack required/excluded tag and item-level constraints, controlled tag validation, stable eligibility diagnostics, and an explicit order-independence contract.
- EQUIP-001/EQUIP-002 expose no domain equipment-change event and permit duplicate collected IDs.
- LOOT-002 validates only the maximum affix count and not rolled ranges or minimum rarity count.
- UI-002/UI-003 build presentation directly in the HUD and compare only damage/speed text rather than a reusable pure view model containing both item sides.
- SALV-001 removes on the first UI press and has no stable transaction/idempotency result.

## Tests defined before production changes

- Unit: weapon definition diagnostics, impossible runtime values, canonical `instance_id`, deterministic unique contexts, and round trip.
- Unit: rarity configuration validation and zero/single-tier weighted boundaries.
- Unit: affix required/excluded tags, level limits, controlled vocabulary failures, structured rejection reasons, duplicate prevention, and order independence.
- Unit: generated affix count/ranges, undersized eligible pools, and exact reconstruction.
- Unit: equipment mutation events, duplicate ownership rejection, wrong-slot non-mutation, stat clamps, source reversibility, salvage plan/commit atomicity, protections, and duplicate commit rejection.
- Unit: tooltip and same-slot comparison view models, empty-slot behavior, fallbacks, long content, and behavior differences without item score.
- Integration: pickup failure preserves the world item, bow projectile cleanup on equipment change, event-driven HUD update, controller salvage confirmation, and comparison refresh after equip.
- Simulation: repeat random equipment operations and batch salvage while preserving ownership/material invariants.

## Implementation sequence

- [x] Extract and audit Tasks 16-30 against code, tests, docs, and evidence.
- [x] Add failing/contract tests and register exact assertion counts.
- [x] Implement pure model, rarity, affix, generator, equipment, tooltip/comparison, and salvage contracts.
- [x] Integrate projectile lifecycle, equipment events, pickup acknowledgement, and controller confirmation.
- [x] Run targeted then full validation and deterministic simulations.
- [x] Capture/review required 1280x800 states and update architecture/design/testing evidence.
- [x] Review diff and archive this plan.

## Result

Completed on 2026-08-09. Godot import, 25 static checks, and 732 automated assertions pass. Windows and Linux exports pass; the exported Windows executable passes an isolated headless launch. Seven reviewed 1280x800 artifacts cover the required M1 and equipment states. Full acceptance mapping and metrics are recorded in `evidence/2026-08-09-tasks-16-30-conformance.md`.

The source document's mandatory real Steam Deck controller-only enjoyment playtest remains an external human hardware gate and is not claimed as passed.
