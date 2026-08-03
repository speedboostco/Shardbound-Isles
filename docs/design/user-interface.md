# User Interface

The reference viewport is 1280x800. HUD information must be legible, anchored safely, and non-authoritative. It observes health, wood, stone, and equipment through state-change signals rather than frame polling. The equipped weapon line shows damage and attack speed, while a bottom-safe contextual prompt names the nearest usable target and its shared `A / E` action without obstructing the center of play. Menus require explicit controller focus and no mandatory text input or mouse hover.

The equipment modal browses every collected item with Previous/Next controls and a selected-position count. It identifies level, slot, rarity by both name and color, base weapon/stat values, every formatted ordinary affix with category, and the full legendary behavior. Comparison is against the currently equipped item in the same slot: signed positive and negative changes remain visible and there is no synthetic item score. Equip, Unequip, Keep/Unfavorite, and Salvage are direct controller actions; equipped and favorited items visibly reject salvage. Opening the modal focuses a valid action and suspends player/enemy movement. Explicit focus neighbors recover when an action disables itself.

The workbench modal browses Reinforced Heart and Runed Whetstone with a 1/2 position indicator. It shows the selected permanent effect, owned versus required resources, affordability, and success or rejection feedback. When a recipe is unaffordable, focus starts on recipe browsing; completion moves focus to an unlocked action. Only one modal can be open, and closing restores gameplay.

The system modal exposes a single local Save and Load slot, displays schema version 5 and explicit results, and focuses Save when opened. Opening it suspends movement, combat, and production. It requires no pointer or text entry.

The M2 equipment layout is visually checked at 1280x800. Long affix and legendary descriptions wrap inside an opaque panel, all actions remain in frame, and controller focus is visible without relying on hover.

The island-shard modal browses owned shards and three stable world slots. It displays biome, level, size, rarity, resources, enemies, positive modifiers, negative risks, special encounter, expected rewards, and any adjacency benefit/price before confirmation. Separate shard and slot controls, Install, Remove, and Cancel are fully focus-connected. Replacement/removal require a second confirmation and explain that active entities will be cleared. The 1280x800 layout wraps all modifier and synergy text without clipping.
