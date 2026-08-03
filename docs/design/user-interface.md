# User Interface

The reference viewport is 1280x800. HUD information must be legible, anchored safely, and non-authoritative. Menus require explicit controller focus and no mandatory text input.

The equipment modal browses every collected item with Previous/Next controls and a selected-position count. It shows equipped state, signed power change, authoritative salvage value, legendary behavior, scrap total, and actions for the selected item. Opening it focuses a valid action and suspends player/enemy movement. Explicit focus neighbors connect selection to Equip/Salvage/Unequip, and focus recovers when an action disables itself.

The workbench modal shows one recipe, its permanent effect, owned versus required resources, affordability, and success or rejection feedback. Only one modal can be open. The first valid action receives focus, and closing restores gameplay.

The system modal exposes a single local Save and Load slot, displays schema version 2 and explicit results, and focuses Save when opened. Opening it suspends movement, combat, and production. It requires no pointer or text entry.

The island-shard modal browses all owned shards and displays shard name, biome, seed, explicit reward and risk, installed state, and install/replace/remove actions. The focused action and physical eastern island slot make world changes visible without pointer input.
