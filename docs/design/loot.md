# Loot

Equipment generation is one deterministic pipeline driven by an explicit seed and context:

1. Choose a base definition and item level.
2. Roll Common, Magic, Rare, Epic, or Legendary rarity.
3. Determine the ordinary-affix count from the rarity contract.
4. Build an eligible, non-conflicting affix pool.
5. Make weighted choices and roll values inside authored ranges.
6. Add an eligible legendary behavior without consuming an ordinary slot.
7. Finalize a plain JSON-serializable item instance with stable identity.

Rarity controls affix opportunities and salvage value, not just color. Rolls overlap deliberately: a higher-rarity item is not guaranteed to be better for a particular build. Every tooltip therefore exposes the base, rolls, and behavior rather than an invented item score.

Items use typed `weapon`, `helmet`, `body`, `boots`, `ring`, and `amulet` slots. Replacing an equipped item leaves the previous item owned. Derived stats are recomputed from immutable bases on every equipment change, so repeated equip operations cannot accumulate modifiers.

Salvage consumes an unequipped, non-favorite item only after the transaction succeeds. Reward scales with rarity and item level. Equipped and favorited items are protected. The equipment screen provides quick equip, unequip, keep/unfavorite, and salvage actions with controller focus.

Ground equipment is capped at 40. When pressure exceeds the cap, the oldest lowest-rarity non-legendary item is removed first; Epic and Legendary drops receive an importance beam, and Legendary drops are never cleanup candidates. Material pickups continue to merge. `LootFilter` already separates keep and optional auto-salvage policy, but automatic salvage is disabled for M2.

The early arena exposes all three weapon families: Tideglass Bow from the first Slime, a seeded Rare sword from the Tide Slinger, and a seeded Epic wand from the Stormcaller. The boss still grants Riftwake Core.
