# Save System

The local single slot is `user://shardbound-save.json` with explicit schema version 3. It stores plain JSON-compatible state: player health and position, wood, stone, scrap, generated equipment definitions including stable ID/seed, equipped ID, Reinforced Heart and Runed Whetstone flags, Tidecatcher construction/stored wood, owned island shards, and the installed shard. Shard modifier extensions remain optional typed fields.

The service writes a temporary file, moves the prior save to a backup, replaces it, rolls back on replacement failure, and removes the backup after success. Decode validates the complete payload and canonicalizes JSON numbers before the world mutates. Malformed JSON, missing state, invalid state, and unsupported schemas are rejected. Schema-1 saves add empty island state plus stone-era defaults; schema-2 saves add `stone = 0` and `runed_whetstone_crafted = false`. Tree/stone/enemy encounter depletion state is intentionally not included yet.
