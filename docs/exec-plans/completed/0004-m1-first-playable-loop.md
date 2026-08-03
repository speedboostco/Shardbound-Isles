# M1 — First Playable Loop

## Goal

Deliver every criterion in `evidence/M1.txt`: a controller-first gather, fight, loot, equip, and power-growth loop that is deterministic, testable, readable at 1280x800, and compatible with the broader existing vertical slice.

## Gap matrix

- PLY-001: movement exists, but pure analog/diagonal/FPS contracts lack automated coverage.
- PLY-002: bounds exist, but smoothing and independently switchable shake do not.
- PLY-003: workbench and rift proximity checks are separate and there is no contextual target/prompt.
- RES-001: tree and stone duplicate runtime code instead of sharing a typed definition-driven node.
- RES-002: magnetic automatic pickup exists, but resource stacks do not merge and the 100-drop case is not validated.
- INV-001: wood and stone are independent world integers without atomic operations or change signals.
- COM-001: player and enemy health logic is duplicated and cannot be tested as a pure component.
- COM-002: direction and cooldown exist, but weapon speed and explicit hit feedback are absent.
- ENM-001: the chaser works, but lacks explicit states, shared health, obstacle recovery, Slime readability, and a second no-loot Slime.
- ITEM-001: equipment dictionaries lack definition/runtime separation, canonical M1 fields, and explicit round-trip coverage.
- LOOT-001: fixed loot works, but every ordinary death currently assumes a drop.
- EQUIP-001: damage changes, but attack speed and compatibility validation do not.
- UI-001: health/resources/equipment exist, but no contextual interaction prompt exists.
- SIM-001: smoke gathers and kills once, but does not move, gather both resources, equip, kill a second Slime, or prove improved effectiveness.

## Assumptions

- Preserve the existing save schema and legacy equipment dictionary keys while adding canonical weapon fields.
- Keep all later vertical-slice content operational; M1 work extends rather than replaces it.
- South face / `E` is the universal interaction action; West face / Space remains attack. Existing dedicated menu shortcuts remain available.
- Resource definitions are typed Resources; tree and stone use one `ResourceNode` runtime script.
- A stateful `ResourceInventory` is authoritative, while `world.wood` and `world.stone` remain compatibility properties for existing tests and saves.
- `HealthComponent` is pure state with signals; player respawn policy and enemy removal remain scene responsibilities.
- Loot is optional per enemy. The first Slime drops deterministic weapon seed `424242`; the second Slime deliberately does not.
- Camera shake is deterministic presentation state, disabled by default, and independent from follow smoothing.
- The 100-drop performance contract is met by same-resource stack coalescing plus a measured generous upper bound, without speculative pooling.

## Acceptance criteria

- Every PLY/RES/INV/COM/ENM/ITEM/LOOT/EQUIP/UI/SIM criterion in `evidence/M1.txt` has code, automated evidence, or an explicitly reported hardware-only limitation.
- Existing post-M1 integration and simulation tests continue to pass.
- Fixed-seed weapon identity and legacy save payloads remain compatible.
- The final simulation gathers wood and stone, kills two Slimes, equips the first drop, and proves fewer hits or higher damage after equipping.
- Visual evidence at 1280x800 shows the readable HUD, interaction prompt, resources, Slime, and equipped state.

## Tests defined before implementation

- Unit: analog movement magnitude, normalized diagonal, and equal displacement across timestep partitions.
- Unit: nearest available interaction target with stable tie-breaking.
- Unit: atomic resource add/remove/set, no negatives, and change signals.
- Unit: damage, healing, invulnerability, one death signal, and revive for shared health.
- Unit: weapon definition/runtime separation, canonical serialization round trip, stable IDs, compatibility rejection, damage, and attack speed.
- Integration: camera smoothing/limits/shake toggle; contextual prompt and universal interaction; definition-driven tree/stone; merged 100-drop case; player cooldown/hit feedback; explicit Slime states/death/obstacle recovery.
- Simulation: fixed M1 path from spawn through second Slime with resource, loot, equip, and effectiveness metrics.

## Progress

- [x] Read M1 and current system-of-record documents.
- [x] Complete the gap matrix and define tests.
- [x] Add pure rule/model tests and implementations.
- [x] Integrate scenes, controls, HUD, and compatibility adapters.
- [x] Extend simulation and capture performance/visual evidence.
- [x] Run full validation, export attempts, and diff review.

## Result

- Godot import and static validation pass; the full suite passes 348 assertions with no failures and writes JUnit.
- The fixed M1 simulation repeats exactly, gathers 3 wood and 2 stone, defeats two Slimes, collects one optional weapon drop, equips it, and reduces the second kill from three hits to one.
- The measured pickup scenario coalesces 100 drops into one stack in 260 microseconds on the validation host.
- The 1280x800 capture verifies a readable event-driven HUD, contextual interaction prompt, world resources, Slime silhouette, and equipped weapon without center obstruction.
- Official Godot 4.7.1 templates were installed locally; Windows and Linux exports both pass with exit 0, and the exported Windows executable completes a headless smoke launch with exit 0. Steam Deck/Proton and the ten-minute physical-controller playthrough remain external hardware validation because this host has neither Proton nor a detected controller.
