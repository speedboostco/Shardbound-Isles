# Animation, Inventory Art, and World-Loot Gate

Status: implementation complete — physical controller validation pending

## Goal

Complete Tasks 46-60 by replacing stiff presentation with a state-driven animation and item-icon foundation, polishing controller-first equipment inspection, and re-validating the existing M3 archipelago implementation as one reproducible world-is-loot loop.

## Assumptions and scope

- Tasks 54-59 are already implemented by the accepted M3 architecture (`ArchipelagoModel`, shard definitions/generator, shard inventory, placement, materialization, persistence). This plan extends and verifies that path; it does not create a competing island system.
- Animation state is presentation-only. Damage, movement, targeting, drops, and save state remain authoritative in their existing gameplay systems.
- The project asset family remains Emberwood. New animation and icon atlases use the same generated-source, deterministic pixel-processing, validation, and provenance pipeline.
- Automated controller input and 1280x800 captures are repository evidence. A physical Steam Deck/controller feel check is external and will not be claimed.

## Acceptance criteria

- Player, slime, ranged enemy, resources, pickups, workbench, and first production building have readable bounded presentation states; player/enemy state priority and transition naming are shared and documented.
- Player presentation contains no persistent selection circle; a subtle non-circular shadow, target highlight, and short-lived combat indicators preserve readability.
- Item definitions resolve data-driven icons; every current equipment/resource/material category has a distinct icon; invalid/missing IDs resolve to a validated fallback.
- The equipment screen presents icon, slot identity, focus, and decision-first comparison clearly at 1280x800 with controller-only navigation.
- Existing shard obtain/inspect/place/materialize/save-load behavior remains deterministic and transaction-safe, and the install moment gains a visible bounded transition.
- A fixed-seed Task 60 scenario records gather, combat, shard reward, inspection, placement, materialization, access, and new opportunity.

## Tests defined before implementation

- Unit: animation state priority, frame selection, clip naming, icon registry coverage/fallback, item-definition icon validation, and atlas contracts.
- Integration: player/enemy state-to-animation bindings, one attack trigger per attack, resource/pickup/object presentation state, interaction targeting after circle removal, item-definition-to-UI icon resolution, controller focus/equip/unequip regression, and install materialization transition.
- Simulation: multiple animated actors/resources under the fixed seed plus the complete Task 60 world-loot route and persistence regression.
- Visual: deterministic 1280x800 animation/readability, equipment/icon, shard inspection, placement, and before/after materialization captures.
- Build: static validation, full validation, Windows export, and exported executable smoke.

## Work sequence

- [x] Add shared animation-state rules and Emberwood animation atlas; bind player/enemy/resource/object presentation.
- [x] Remove persistent player-circle presentation while preserving interaction and combat readability.
- [x] Add the item-icon atlas, registry, definition references, fallback validation, and art-bible rules.
- [x] Polish equipment layout, icon/slot presentation, decision-first comparison, and controller focus.
- [x] Add bounded island materialization presentation and Task 60 fixed-seed evidence without duplicating M3 domain systems.
- [x] Run targeted/full validation, capture 1280x800 evidence, export Windows, and review the diff.
- [ ] Run the controller-only Task 60 route on physical Steam Deck-class hardware; confirm animation feel, stick repeat, focus comfort, and installation payoff before closing the experiential gate.

## Risks and rollback

- Generated atlas poses may be unclear at runtime size. Keep semantic atlas coordinates isolated in `VisualAssetLibrary`; rollback is asset/coordinate-local.
- Animation can drift from combat timing. Drive attack presentation from the existing attack event and keep gameplay hit timing unchanged.
- UI changes can break focus paths. Preserve action wiring and assert focus/controller traversal before visual sign-off.
- Materialization VFX can obscure or allocate excessively. Bound lifetime/count and keep it outside serialized island state.
