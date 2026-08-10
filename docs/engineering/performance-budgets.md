# Performance Budgets

## Emberwood visual pass

Each visible hero, normal enemy, tree, stone, pickup, or temporary plant receives one presentation sprite. Arena terrain is one retained root draw using 64px cells; decorative leaf/stone accents are deterministic, non-colliding, and present in roughly 10-15% of grass cells. VFX live at most 0.68 seconds (0.85 hard art-bible limit), are group-trackable, and do not process after cleanup.

Before visual integration, the stable simulation suite completed in 2290.7 ms on the Windows validation host. The new gate separately creates and retires 300 mixed hit/critical effects in 6,170 microseconds while returning the active VFX group to zero; final stable-suite elapsed time is recorded in Task 45 evidence. These are algorithmic/lifecycle comparisons, not Steam Deck frame-time certification.

Reference resolution is 1280x800. Ordinary play targets stable 60 FPS; validated worst cases must remain at least 30 FPS. Establish measured scenarios before optimization. Avoid unnecessary per-frame work and speculative pooling.

The M1 pickup scenario spawns 100 colocated drops through the normal world API. Same-resource drops coalesce into one magnetic stack, and the integration contract requires the operation to complete in less than 500 ms while preserving all 100 units. The test prints `M1_PICKUP_METRICS` so CI logs retain the measured duration. This is a regression guard for the explicit M1 case, not a substitute for Steam Deck frame-time profiling.

M2 bounds ground equipment to 40 nodes and caps active Living Arrow plants at three. The final 10,000-item generator validation completed in 1,253,781 microseconds on the Windows development host. A 1,000-event Chain Mining stress contract completed in 11,376 microseconds with 145 bounded effects. These deterministic CI guards detect algorithmic regressions; they are not Steam Deck frame-time certification.

M3 limits the current archipelago to three materialized islands. Neighbor/synergy state recalculates only on graph mutation, never per frame. The final 10,000-shard validation exercised all six biomes and definition rules in 302,394 microseconds on the Windows development host. This is an algorithmic regression guard, not Steam Deck frame-time certification.

M4 live automation ticks at 0.5-second intervals. A collector processes at most 8 eligible pickups per batch and stores at most 12 units; shared storage holds 24; mill input/output hold 12/8. Offline catch-up is one bounded calculation capped at four hours, not a replay of frames. The deterministic simulation asserts these limits and identical results across elapsed-time chunking; Steam Deck stress certification remains M6 work.
