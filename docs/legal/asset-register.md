# Asset Register

Only assets listed here may enter production scenes. Presentation families are selected per responsibility and remain isolated behind semantic runtime libraries.

## Selected cohesive actor and world family: Shade Puny CC0

| Field | Record |
|---|---|
| Stable family ID | `shade_puny_cc0` |
| Location | `assets/third_party/shade/puny_cc0/` |
| Source/author | Shade; official Puny Characters OpenGameArt distribution and official Puny World itch.io distribution, retrieved 2026-08-18 |
| Rights basis | Creative Commons Zero 1.0 Universal on both official listings; retained as `LICENSE.txt` |
| Modification/commercial use | Permitted by CC0; attribution is not required, but source and author remain in `PROVENANCE.md` |
| Redistribution | Runtime derivatives and retained CC0 notice may ship; exact expanded sources remain under ignored `source/` and are excluded from export |
| Covered categories | Warrior protagonist; Orc, Archer, and Mage enemy roles; eight-direction idle/walk/sword/bow/staff/throw/hurt/death frames; grass and directional dirt paths; trees and source flowers; matching project-authored boulder and flora variants |
| Deterministic transform | `tools/puny_asset_builder.gd` maps opaque pixels to one 16-color palette, thresholds alpha, preserves all actor frames, and builds three fixed-mask 16px object variants |
| Not covered | UI, item icons, structures, signature Legendary effects, audio, or marketing art |
| Replacement risk | Medium for visual identity; gameplay/save state stores only semantic actor/state/facing/object IDs and never source filenames or atlas cells |

## Selected production family: Emberwood v3

| Field | Record |
|---|---|
| Stable family ID | `emberwood_v3` |
| Location | `assets/original/emberwood/` |
| Source/author | Project-created, AI-assisted with OpenAI built-in image generation on 2026-08-10 and expanded on 2026-08-18, including the living-world atlas; exact prompts recorded in the linked evidence documents |
| Rights basis | Project-original generated output supplied for this project; third-party terrain is tracked separately below |
| Project permission | May be used, modified, imported, exported, and replaced inside Shardbound Isles |
| Attribution | No in-game attribution required by the selected project asset policy |
| Redistribution | Ship only the runtime atlas/imported derivative in game builds; do not redistribute the chroma-key source master as an asset pack |
| Covered categories | Legacy hero fallback; Slime, Forest Ranger, elite, and Abyssal Warden states; tree, stone, Moonleaf, workbench, mill, collector, storage, Tidecatcher, portal/event/pedestal; Moonleaf Thicket, Tidewell, Whispering Shrine, and Firefly Hollow state sets; 64 item/shard/status icons; forest/path/special terrain; eight animated VFX lines; original Legendary/plant emblem |
| Not covered | Full multi-direction enemy locomotion, 4-8 frame character death clips, biome-wide content sets beyond their registered ground/landmark concepts, marketing art, audio |
| Replacement risk | Hero, Ranger, Warden, and Legendary emblems are visually distinctive; retain semantic IDs and revalidate captures if any are redrawn before final marketing lock |

The source master is kept in an ignored `source/` directory for provenance and editing, not as a runtime resource.

## Retained legacy terrain and actor family: Tiny Swords CC0

| Field | Record |
|---|---|
| Stable family ID | `pixel_frog_tiny_swords_cc0` |
| Location | `assets/third_party/pixel_frog/tiny_swords_cc0/` |
| Source/author | Pixel Frog; Tiny Swords Update 010 CC0 edition, retrieved from the Agent Quest CC0 bundle at revision `010c791207c9e5670f07d0fbca3a62f3d1eb0fa7` |
| Rights basis | CC0 1.0 Universal; exact supplied license retained as `LICENSE.txt` |
| Modification/commercial use | Permitted by the retained CC0 dedication |
| Attribution | Not required; author and source retained in `PROVENANCE.md` |
| Redistribution | Permitted by CC0; selected terrain/actor sources, deterministic runtime atlases, and the retained license/provenance are included; source sheets remain excluded from Godot export |
| Covered categories | Starting-island grass/path terrain; bounded background decorations; retained rollback hero sheets; Red TNT Goblin chaser; Red/Purple Archers; Purple Torch Goblin Warden; authored enemy idle/move/attack frames |
| Not covered | UI, buildings, interactive props, loot, signature Legendary VFX, audio, marketing art, or dedicated Archer locomotion/death clips absent from this CC0 edition |
| Replacement risk | High for actors and medium for terrain; semantic animation IDs isolate gameplay/save data from atlas cells, but silhouettes and visual identity would change |

## Retained legacy protagonist: Hormelz Knight CC0

| Field | Record |
|---|---|
| Stable family ID | `hormelz_knight_cc0` |
| Location | `assets/third_party/hormelz/knight_cc0/` |
| Source/author | Hormelz; 8 Directional Knight Character, official free Knight-Only bundles from https://hormelz.itch.io/8-directional-knight |
| Retrieved | 2026-08-18 through the official itch.io free-download flow; upload files `(Free)KnightBasic.rar`, `(Free)KnightAdvCombat.rar`, and `(Free)KnightExMovement.rar` |
| Rights basis | Creative Commons Zero v1.0 Universal, as declared by the official source page; project copy retained as `LICENSE.txt` |
| Modification/commercial use | Permitted by CC0 |
| Attribution | Not required; Hormelz and the source URL remain in `PROVENANCE.md` and `SOURCE_NOTICE.md` |
| Redistribution | Permitted by CC0; source PNG/JSON and derived runtime atlases are included, while redundant GIF/RAR containers and all paid variants are excluded |
| Covered categories | One coherent armored hero; eight-direction idle/run; unarmed physical, melee spin, ranged draw, and arcane cast actions; impact; complete death sequence |
| Not covered | Paid sword or shield layers, enemy art, terrain, UI, audio, or marketing art |
| Deterministic transform | Exact JSON frame order; stable 128px crop, with a 160px nearest-reduced death envelope; 16-column atlases no larger than 2048px; no mirroring, synthesis, redrawing, or AI generation |
| Replacement risk | Medium-high for visual identity; gameplay/save state retains only semantic facing/state/equipment data and never stores source names or atlas cells |

An external asset may not be added until its source, author, exact license version or purchase terms, modification right, attribution duty, redistribution limits, and replacement risk are recorded in this file.
