# Affixes

Ordinary affixes are authored in `AffixRegistry`; generators and UI read the registry instead of matching IDs. Each definition has a stable ID, category, eligible item tags/slots, numeric range, selection weight, stat operation, tags, and optional conflict group. The current pool contains 16 affixes across offensive, defensive, utility, gathering, production, and hybrid categories.

Eligibility is evaluated before every weighted choice. Weapon-only rolls cannot appear on armor, `living_quiver` is bow-only, and mutually exclusive elemental conversion groups such as Emberbound and Frostbound cannot occur together. An item cannot roll the same ordinary affix twice. Registry validation rejects invalid ranges, weights, categories, references, or duplicate IDs.

Legendary behaviors are separate components registered in `LegendaryBehaviorRegistry`. They do not consume an ordinary affix slot and are attached only while their item is equipped. The event boundary supports attacks, kills, resource hits, and resource use without a switch on legendary item IDs.

- `riftwake_pulse`: emits a deterministic secondary pulse after an attack.
- `chain_mining`: chains a resource hit to at most four nearby resources/enemies, with a cooldown and recursion guard.
- `burning_smelter`: a burning kill smelts the nearest ore or safely grants one stored charge.
- `living_arrows`: some bow attacks grow temporary attacking plants, capped at three and never persisted.

Components disconnect cleanly on unequip. World presentation listens for triggered-effect events and renders a distinct short-lived ring for feedback.
