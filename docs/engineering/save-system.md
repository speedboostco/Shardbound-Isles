# Save System

The local single slot is `user://shardbound-save.json` with explicit schema version 1. It stores plain JSON-compatible state: player health and position, wood, scrap, generated equipment definitions including stable ID/seed, equipped ID, Reinforced Heart state, Tidecatcher construction, and stored wood.

The service writes a temporary file, moves the prior save to a backup, replaces it, rolls back on replacement failure, and removes the backup after success. Decode validates the complete payload and canonicalizes JSON numbers before the world mutates. Malformed JSON, missing state, invalid state, and unsupported schemas are rejected. Tree/enemy encounter state is intentionally not included yet.
