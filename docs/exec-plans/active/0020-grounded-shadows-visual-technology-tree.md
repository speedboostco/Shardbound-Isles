# Grounded Shadows and Visual Technology Tree

## Goal

Make characters and world props read as planted on the terrain, then replace the compact text-only technology selector with a controller-first visual tree that explains branches, benefits, prerequisites, costs, and the recipes each node unlocks.

## Product assumptions

- This is a focused presentation/progression pass, not an attempt to add the content volume of an AAA production.
- Technology remains resource-funded and deterministic; the UI does not own progression state.
- The existing inventory modal is the entry point. A dedicated page inside it provides enough space for the tree without adding another global menu.
- Existing authored iconography is reused so the tree stays visually cohesive.

## Acceptance criteria

- Player, enemies, residents, harvestables, obstacles, and animated world props use narrow contact shadows aligned to their ground contact instead of broad detached ovals.
- Shadow profiles have bounded opacity, vertical scale, and footprint dimensions and are covered by a deterministic unit test.
- The inventory exposes a dedicated technology page that is fully navigable by controller and returns focus safely.
- Seven technology nodes are drawn as a connected graph with icons and learned/available/locked/selected states.
- The selected node shows a plain-language description, prerequisites, exact resource cost, status, and named recipe unlocks.
- Three advanced technologies unlock three additional unique recipes with real gameplay-stat effects.
- Technology and recipe registries validate all icon, graph-position, and unlock references.
- The UI fits and remains readable at 1280x800.

## Test-first evidence

- Extend `progression_mana_test.gd` with technology presentation-contract and recipe-unlock assertions.
- Extend `exploration_progression_targeting_flow_test.gd` with visual-page/controller-focus assertions.
- Add a contact-shadow profile unit test.
- Run unit and integration suites before full validation.

## Implementation steps

1. Add a shared contact-shadow renderer/profile registry and migrate ground-bound sprites.
2. Add graph metadata and explicit recipe unlocks to technology definitions.
3. Add three validated advanced recipes and apply their permanent stat effects.
4. Add a custom technology graph control and dedicated inventory sub-page.
5. Capture the grounded world and technology page at 1280x800.
6. Run full validation, Windows export, exported-build smoke, and review the diff.

## Status

Complete.

## Verification

- `test-unit`: 549 assertions, 0 failures.
- `test-integration`: 386 assertions, 0 failures.
- `static-validate`: 26 checks, 0 failures.
- `validate`: 1,030 assertions, 0 failures.
- 1280x800 evidence: grounded world and complete technology page, visually reviewed for clipping, focus, icon readability, and layer integrity.
- `export-windows`: success; exported executable launched at 1280x800 and exited normally after 180 frames.
- The recurring Windows root-certificate-store diagnostic remains non-fatal and unrelated to project content.

## Design references

- Enshrouded's official 2026 skill-tree update emphasizes improved layout, overview, clearer paths, and updated visuals; this pass applies those principles at the slice's seven-node scale.
- Grounded's official progression notes repeatedly connect exploration or progression unlocks to new crafting recipes and alternate crafting methods; this pass makes every technology's recipe reward explicit before purchase.
