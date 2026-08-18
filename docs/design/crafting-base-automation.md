# Crafting, Base, and Automation

M4 turns manually gathered resources into a compact, optional labor-saving base. It deliberately proves one understandable flow rather than introducing conveyors:

`ordinary world drops → collector → shared storage → lumber mill → planks → player/crafting`

## Recipes and workbench

`RecipeRegistry` owns authored inputs, outputs, station IDs, unlock requirements, uniqueness, display names, and effects. `CraftingService.evaluate` returns an immutable transaction plan: all requirements and output capacity are checked before it describes any deduction. Unknown resource, output, station, and unlock IDs fail validation.

The controller workbench browses eighteen registry entries. Reinforced Heart, Runed Whetstone, and Herbal Compass are the first three useful permanent objects. Lumber Mill Kit and Collector Kit enter placement after a successful atomic craft. Technology paths add mana, ranger, foraging, traversal, damage, shard, and production recipes; each authored unlock names a concrete effect before purchase. Missing resources and locked requirements are shown explicitly.

## Placement

M4 uses four authored base sockets. This is a deliberate compact-base constraint, not a placeholder for a free-form grid. The placement model owns committed building IDs, stable socket IDs, coordinates, and 90-degree rotation. It rejects player overlap, blocked cells, and occupied sockets.

Preview nodes are presentation only. They show green for valid and red for invalid placement and are destroyed on confirm/cancel. Only committed model data is serialized. Controller focus exposes previous/next socket, rotate, place, and cancel without pointer input.

## Automation

The collector handles only ordinary world-owned `wood`, `stone`, and `moonleaf` drops within 180 pixels. It excludes rare drops, encounter rewards, equipment, shards, and player-owned pickups. Each pass handles at most eight targets and stores at most twelve resource units.

Shared storage holds 24 total units. Every add reports accepted and remainder quantities, so overflow never deletes resources. The lumber mill has independent 12-wood input and 8-plank output inventories. Every three seconds it atomically turns two wood into one plank. Full output blocks without consuming input.

The workbench exposes focused `Deposit All Wood` and `Collect Planks` actions, making the first mill usable before a collector exists. Buttons show current quantities and disable when no transfer can occur.

Live automation runs on a 0.5-second timer, not per-building or per-target frame callbacks. Offscreen/offline work uses the same deterministic batch rules, clamps negative elapsed time to zero, caps catch-up at four hours, and is always bounded again by input/output/storage capacity. Island Industry and Precision Gearbox multiply the shared effective elapsed-time input, so the production upgrade behaves identically online and offline without bypassing capacity limits.

## Item upgrades

The workbench upgrade station sharpens equipped weapons from +0 to +10. The next cost is `2 + 2 × current level` scrap; +7 through +10 additionally use one Moonleaf. The power bonus is bounded at +5 by +10, preserving loot/affixes as the main source of build power.

There is no failure roll, item destruction, affix replacement, or legendary behavior removal. The UI shows exact level, power, and cost before requiring a second confirmation press.

## Persistence

Save schema 6 stores committed building placement, shared storage, both building-local inventories, mill progress, collector buffer, unplaced crafted kits, item upgrade fields, planks, and a simulation timestamp. Schema-5 saves migrate to an empty M4 base without losing M1–M3 state. Loading applies bounded catch-up only after the complete payload validates.
