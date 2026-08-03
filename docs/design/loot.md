# Loot

Loot generation is deterministic for an explicit seed and generation context. `WeaponDefinition` contains immutable authored data while `WeaponInstance` contains runtime identity and rolls. Canonical weapon state includes `item_id`, `base_type`, `damage`, `attack_speed`, `rarity`, and `seed`; serialization and restoration preserve the same stable context/type/seed instance ID. Legacy keys remain readable for schema-3 save compatibility.

Collected equipment enters authoritative inventory state. Previous/Next controls browse every owned item while the panel shows its position, power comparison, attack speed, affix, and authoritative salvage value. Equip and Salvage act on the displayed index; selection clamps after removal. Equipping one compatible weapon changes both actual attack damage and cooldown; the previous weapon remains owned. Incompatible base types are rejected. An equipped item must be unequipped before salvage, preventing accidental destruction.

Salvage values are shared domain rules used by both the inventory action and its UI: common 1, uncommon 2, rare 4, and legendary 10 scrap.

The Abyssal Warden drops Riftwake Core (`riftwake_core_7777`), a deterministic legendary magic item with power 9 and seed `7777`. Its stable `riftwake_pulse` affix changes attacks into an area effect: the primary strike resolves first, then a visible 115-pixel pulse deals 2 damage to nearby secondary enemies. Legendary items salvage for 10 scrap under the existing rarity rule.

Each completed rift drops one rare Rift Cache with stable run-indexed ID/seed beginning at `rift_cache_8801`. Power is 7, 8, then capped at 9 for later runs; repeatability does not create unbounded numerical scaling.
