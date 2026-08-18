# Survival Gathering and First-Hour Journey

## Goal

Add preparation-focused survival, broaden deliberate resource gathering, and guide the current systems through a controller-first first-hour journal without introducing punitive hunger or thirst.

## Assumptions

- Survival should reward preparation and recovery rather than drain meters while the player explores.
- New resources must have immediate consumers; fiber and emberberry exist to produce Trail Rations.
- The journal observes authoritative gameplay events and persists stable milestone IDs; UI does not own progression.
- Existing herb presentation can support two authored forage variants without adding a new art dependency.

## Acceptance criteria

- Two fiber patches and two emberberry bushes are gatherable in the safe opening and use normal collision, hit feedback, drops, and pickup attraction.
- A repeatable Trail Ration recipe consumes two fiber and two emberberries and respects a three-ration capacity.
- Resting at the field camp consumes one ration, restores bounded health and mana, and grants six prepared harvests with +1 yield.
- No survival value decreases with wall-clock time and there is no death/health penalty for ignoring preparation.
- An eleven-step controller-first journey journal tracks gathering, preparation, technologies, loot, shards, installation, and base construction.
- Completed journal milestones grant their authored reward once and journal/survival state round-trips through schema 8.
- Field objectives show the next journey step and inventory exposes both the technology tree and journey journal.
- Automated unit and integration tests cover caps, rewards, ordering, gathering, resting, controller focus, and persistence.
- New 1280x800 evidence shows the field resources/camp and the journal without clipping.

## Test-first plan

- Add a pure survival/journey unit suite before scene integration.
- Add an integration route that gathers the new resources, crafts and consumes a ration, verifies the prepared yield, opens the journal with controller focus, and round-trips state.
- Keep existing deterministic suites intact except for authored recipe/save-schema expectations.

## Status

Complete.

## Verification

- `test-unit`: 579 assertions, 0 failures.
- `test-integration`: 409 assertions, 0 failures.
- `validate`: 26 static checks and 1,083 total assertions, 0 failures.
- `export-windows`: completed with exit code 0.
- Exported `ShardboundIsles.exe` smoke-launched at 1280x800 and exited normally with code 0.
- Reviewed `survival-foraging-camp-1280x800.png`, `journey-journal-1280x800.png`, and the updated `inventory-technology-1280x800.png`; all actions and text remain inside the reference viewport with visible controller focus.

The Windows environment continues to emit Godot's non-fatal root-certificate-store diagnostic; the offline game does not depend on the certificate store.
