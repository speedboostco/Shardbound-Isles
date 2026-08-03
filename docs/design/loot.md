# Loot

Loot generation is deterministic for an explicit seed. Definitions and generated item state are plain typed data, independent of scenes.

Collected equipment enters authoritative inventory state. The equipment panel compares its power against the equipped item. Equipping adds item power to the base attack damage; uncommon starter equipment salvages for two scrap. An equipped item must be unequipped before salvage, preventing accidental destruction.
