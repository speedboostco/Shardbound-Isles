# Resources

Resource nodes use one `ResourceNode` scene behavior configured by typed `ResourceNodeDefinition` resources. Definitions own hit points, resource ID, yield, and presentation kind; the runtime node owns only current damage state and world feedback. Nodes take discrete hits and show an inspectable visual damage stage.

- The tree takes two hits and yields 3 wood, with island modifiers changing its yield and density.
- The stone outcrop at `(390, -80)` takes three hits, gains visible branching cracks after each impact, and yields 2 stone through a distinct gray-blue pickup.

Destroyed nodes create physical pickups that merge with nearby stacks of the same resource, move magnetically to the player, and collect automatically at close range. A measured integration scenario coalesces 100 same-resource drops into one physical stack within a 500 ms test budget.

`ResourceInventory` is the authoritative non-negative quantity store. Its atomic add/remove operations emit change signals used by the HUD and save-compatible world properties. Stone's first sink is the permanent Runed Whetstone workbench upgrade.

Forest islands add Moonleaf as a one-hit herbal resource with its own pickup identity and HUD counter. Three Moonleaf craft the one-time Herbal Compass, permanently adding 40 pixels of pickup radius; the resource therefore has a specific progression use.
