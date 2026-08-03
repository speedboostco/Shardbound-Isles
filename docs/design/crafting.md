# Crafting

Recipes turn gathered resources into meaningful upgrades or buildings. UI requests actions but never owns inventory state.

The workbench browses two unique upgrades with controller Previous/Next controls:

- Reinforced Heart costs 3 wood and 2 salvage scrap, permanently adds 2 maximum health, and heals the added amount.
- Runed Whetstone costs 2 stone and permanently adds 1 base attack damage before equipment and island bonuses.

Validation occurs in pure domain logic before the world deducts resources. Insufficient or duplicate attempts consume nothing and produce explicit feedback. Saves store crafted flags rather than computed bonuses, so derived stats cannot stack during refresh or load.
