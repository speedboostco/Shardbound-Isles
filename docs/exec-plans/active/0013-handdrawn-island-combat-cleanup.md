# Hand-Drawn Island And Combat Cleanup

Status: complete

## Goal

Remove circular combat overlays and recurring walking-frame bleed, reduce enemy wave pressure, and rebuild the starting island presentation around a coherent hand-drawn 64px terrain set with readable shores, water, paths, and functional world detail.

## Assumptions and source choice

- “Attach” is interpreted as attack. Full or near-full circles around hero/enemies during attack or invulnerability are the reported artifacts; compact shadows remain because they ground sprites.
- The recurring line above walking frames is atlas-cell bleed. Cleanup must be deterministic in the asset pipeline, not hand-erased only in the current PNG.
- “Enemies spawning too fast” refers to the Rift wave system, the only automatic enemy spawning loop. Each wave will be reduced from two enemies to one and separated by a visible respite.
- External art must have explicit commercial/modification rights. The selected source is Pixel Frog’s 64x64 Tiny Swords terrain/decorations from the separately identified CC0 edition. Only terrain/decorative derivatives enter the project; characters and UI remain Emberwood.
- Downloaded provenance/license files are retained beside the selected runtime derivatives. Raw archives are not committed to the runtime tree.

## Acceptance criteria

- Hero, Slime, Ranger, elite, and Warden use no full/near-full hit or attack circles. Attack direction remains readable through wedges, lines, sprite poses, and VFX.
- Hero walking in all four facings has no line or neighboring-frame spill above the head.
- Rift waves contain one enemy each and expose a 2.75-second deterministic respite before the next wave; no hidden immediate spawn occurs.
- The core island reads as a bounded landmass with painted water, leaf-fringed shoreline, authored paths, and varied hand-crafted ground texture rather than a rectangular repeated carpet.
- Terrain remains non-authoritative: collision, deterministic routes, resources, encounters, saves, and controller interaction keep their contracts.
- External asset author, source URL, exact license, modification/redistribution constraints, selected files, and replacement risk are recorded.
- Scene remains readable at 1280x800 and passes full validation/export.

## Tests defined before implementation

- Unit: combat presentation reports no circular overlay; every hero locomotion row has a clean top edge; Rift rules expose one enemy per wave and the fixed respite.
- Integration: hit/attack state keeps sprite/VFX feedback without circular overlay; clearing a Rift wave leaves zero enemies during respite and exactly one after explicit delay advancement.
- Simulation: three-wave route observes a maximum active count of one and two inter-wave respites before deterministic completion.
- Visual: isolated four-direction walking frames, combat telegraphs, shoreline/water, and full starting-island captures at 1280x800.
- Build: `static-validate`, full `validate`, Windows export, and exported executable smoke.

## Work sequence

- [x] Identify overlay, bleed, spawn, terrain, and license boundaries.
- [x] Import and register the selected Tiny Swords CC0 terrain subset.
- [x] Replace combat circles, clean locomotion cells, and pace Rift waves.
- [x] Recompose island terrain without changing authority.
- [x] Add/update unit, integration, simulation, art, and visual checks.
- [x] Validate, export, inspect captures/diff, and record evidence/limitations.

## Risks and rollback

- Mixing art families can look incoherent. Restrict the external pack to terrain/decoration, recolor only when needed, and compare gameplay captures before replacing the current atlas.
- Shore/elevation layers can imply collision that does not exist. Keep the playable boundary and collision rules unchanged until explicit navigation geometry is added.
- Respite logic can stall a run. Own it in one explicit countdown with deterministic test advancement and cleanup on fail/exit.
- Reduced telegraphs can hurt readability. Preserve direction, anticipation duration, contrast, and distinct attack poses while removing only circular geometry.
