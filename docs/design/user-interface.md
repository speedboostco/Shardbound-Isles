# User Interface

The reference viewport is 1280x800. HUD information must be legible, anchored safely, and non-authoritative. Menus require explicit controller focus and no mandatory text input.

The equipment modal shows the first collected item, equipped state, signed power change, salvage value, scrap total, and actions. Opening it focuses a valid action and suspends player/enemy movement. Equip, salvage, unequip, and close are controller navigable.

The workbench modal shows one recipe, its permanent effect, owned versus required resources, affordability, and success or rejection feedback. Only one modal can be open. The first valid action receives focus, and closing restores gameplay.

The system modal exposes a single local Save and Load slot, displays schema version 1 and explicit results, and focuses Save when opened. Opening it suspends movement, combat, and production. It requires no pointer or text entry.
