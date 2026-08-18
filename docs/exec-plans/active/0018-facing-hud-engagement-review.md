# 0018 — Facing, HUD containment, and engagement review

Status: complete (2026-08-18)

## Goal

Correct the horizontally inverted Puny actor rows, bound the HUD health bar inside the status panel, and produce a research-grounded, non-manipulative improvement backlog for sustained player enjoyment.

## Acceptance criteria

- Right input selects the authored east-facing row and left input selects west, including diagonals.
- The mapping is explicit and regression-tested rather than dependent on semantic-array order.
- At 1280x800 the health bar is no wider than 280 pixels and keeps visible padding inside the status panel.
- Existing combat direction, controller, UI, and full validation suites remain green.
- Recommendations prioritize autonomy, competence, meaningful novelty, clear feedback, and healthy stopping points; no paid random rewards, FOMO, or daily-streak pressure.

## Test plan

1. Unit-test the complete semantic-facing to Puny-row mapping and explicit east/west rows.
2. Integration-test the resolved health-bar rectangle against the rendered HUD backdrop.
3. Capture and inspect the eight-direction board and normal 1280x800 HUD.
4. Run full validation and Windows export.

## Progress

- [x] Reproduce and identify both layout defects.
- [x] Add regression tests.
- [x] Implement facing and HUD fixes.
- [x] Capture visual evidence and run full validation/export.
- [x] Record research-backed recommendations and close the plan.
