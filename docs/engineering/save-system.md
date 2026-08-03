# Save System

The local single slot is `user://shardbound-save.json` with explicit schema version 5. It stores plain JSON-compatible player/resources/equipment/crafting/automation state, shard inventory, and the complete Node-free archipelago model. Installed islands retain their definition/seed plus runtime version, destroyed resource IDs, collected reward IDs, and encounter completion. Temporary enemies, projectiles, visuals, and Node references are never saved.

The service writes a temporary file, backs up the prior save, replaces it, rolls back on failure, and removes the backup after success. Decode validates the complete payload and canonicalizes JSON numbers before the world mutates. Invalid slots, definitions, runtime versions, references, or unsupported document schemas are rejected safely.

Schema 1 adds island and stone-era defaults, schema 2 adds stone/Whetstone state, schema 3 migrates the equipped weapon into typed slots, and schema 4 adds Moonleaf/Herbal Compass defaults and migrates a legacy installed shard into the East slot of a schema-5 archipelago. Loading materializes from authoritative data, so destroyed resources do not return and encounter rewards cannot be claimed twice.
