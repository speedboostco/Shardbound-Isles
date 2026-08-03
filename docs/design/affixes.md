# Affixes

Affixes use stable IDs and keep their rules outside scene presentation. Riftwake Core proves the first behavior-changing legendary affix:

- `riftwake_pulse`: every attack emits a visible 115-pixel radial pulse after its primary strike.
- The pulse deals 2 damage once to each eligible secondary enemy inside its radius.
- The primary target is excluded, so the affix cannot double-hit it.
- Candidate selection is deterministic by distance and then stable ID.

Ordinary affix pools, eligibility rules, and deterministic weighting remain deferred until there is a second equipment choice that needs them.
