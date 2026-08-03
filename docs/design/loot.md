# Loot

Loot generation is deterministic for an explicit seed. Definitions and generated item state are plain typed data, independent of scenes.

Collected equipment enters authoritative inventory state. Previous/Next controls browse every owned item while the panel shows its position, power comparison, affix, and authoritative salvage value. Equip and Salvage act on the displayed index; selection clamps after removal. Equipping adds item power to base attack damage, including any installed-island bonus. An equipped item must be unequipped before salvage, preventing accidental destruction.

Salvage values are shared domain rules used by both the inventory action and its UI: common 1, uncommon 2, rare 4, and legendary 10 scrap.

The Abyssal Warden drops Riftwake Core (`riftwake_core_7777`), a deterministic legendary magic item with power 9 and seed `7777`. Its stable `riftwake_pulse` affix changes attacks into an area effect: the primary strike resolves first, then a visible 115-pixel pulse deals 2 damage to nearby secondary enemies. Legendary items salvage for 10 scrap under the existing rarity rule.

Each completed rift drops one rare Rift Cache with stable run-indexed ID/seed beginning at `rift_cache_8801`. Power is 7, 8, then capped at 9 for later runs; repeatability does not create unbounded numerical scaling.
