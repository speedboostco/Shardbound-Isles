# Crafting

Recipes turn gathered resources into meaningful upgrades or buildings. UI requests actions but never owns inventory state.

The first workbench recipe is the unique Reinforced Heart. It costs 3 wood and 2 salvage scrap and permanently adds 2 maximum health, also healing the added amount. Validation occurs in pure domain logic before the world deducts resources. Insufficient or duplicate attempts consume nothing and produce explicit feedback.
