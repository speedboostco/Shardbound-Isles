# Performance Budgets

Reference resolution is 1280x800. Ordinary play targets stable 60 FPS; validated worst cases must remain at least 30 FPS. Establish measured scenarios before optimization. Avoid unnecessary per-frame work and speculative pooling.

The M1 pickup scenario spawns 100 colocated drops through the normal world API. Same-resource drops coalesce into one magnetic stack, and the integration contract requires the operation to complete in less than 500 ms while preserving all 100 units. The test prints `M1_PICKUP_METRICS` so CI logs retain the measured duration. This is a regression guard for the explicit M1 case, not a substitute for Steam Deck frame-time profiling.
