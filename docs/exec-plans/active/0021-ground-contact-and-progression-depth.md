# Ground Contact and Progression Depth

## Goal

Correct the remaining detached-sprite appearance and extend the current vertical slice with a coherent second progression tier rather than disconnected content volume.

## Assumptions

- The visible gap is caused by shadow centers authored below the actual sprite baseline; opacity alone cannot fix it.
- Existing resources, workbench, save dictionary, technology transaction, and icon atlas are sufficient. No new dependency or save schema is required.
- Deeper progression should reinforce combat, gathering, magic, island exploration, and compact automation with visible, testable effects.

## Acceptance criteria

- Every shared contact-shadow profile is centered no more than ten pixels below its owning ground origin.
- Dynamic obstacle shadows use the same bounded contact baseline.
- A new 1280x800 world capture shows no visible air gap between representative sprites and their shadows.
- The technology graph contains twelve validated nodes arranged across four tiers and four disciplines.
- Five new late technologies have real direct effects and each names one new recipe unlock.
- The workbench contains eighteen validated recipes total.
- Duelist Grip, Reinforced Axe, Precision Gearbox, Shard Prism, and Ley Capacitor have distinct, persisted gameplay effects.
- Production-speed progression affects both live and offline mill simulation through the existing bounded automation path.
- Inventory statistics expose production speed; the visual tree remains readable and controller-first at 1280x800.

## Test-first plan

- Tighten `contact_shadow_profile_test.gd` to assert the actual contact baseline.
- Extend `progression_mana_test.gd` to assert twelve graph nodes, eighteen recipes, and all five late unlock links.
- Extend the exploration/progression integration route to exercise every new crafted-effect consumer and production-speed scaling.
- Keep all existing deterministic suites unchanged except for authored count expectations.

## Status

Complete.

## Verification

- `test-unit`: 555 assertions, 0 failures.
- `test-integration`: 393 assertions, 0 failures.
- `validate`: 26 static checks and 1,043 total assertions, 0 failures.
- `export-windows`: completed with exit code 0.
- Exported `ShardboundIsles.exe` smoke-launched at 1280x800 and exited normally with code 0.
- Reviewed `grounded-contact-shadows-1280x800.png`, `visual-technology-tree-1280x800.png`, and `inventory-technology-1280x800.png` for grounding, clipping, hierarchy, and controller-visible actions.

The Windows environment continues to emit Godot's non-fatal root-certificate-store diagnostic during startup and export; no online feature is required by the game.
