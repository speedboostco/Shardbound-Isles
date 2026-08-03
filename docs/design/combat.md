# Combat

The player uses a short-range directional strike aimed by the latest non-zero movement input. Attack speed controls its real cooldown, and each swing chooses at most one primary target so one hit cannot apply damage repeatedly. Successful hits flash the attacker and target. Player and enemies share `HealthComponent`; it clamps damage/healing, emits death once, and gives the player 0.45 seconds of post-hit invulnerability.

The first ordinary melee enemy is a green Slime with explicit Idle, Chase, Attack, and Dead states. It has collision recovery around simple obstacles, stops immediately after death, and takes three unarmed hits in the M1 scenario. The first Slime drops the seeded starter weapon; the second deliberately drops no item, proving that loot is optional per death.

The Tide Slinger is the second ordinary archetype: it maintains range, displays a 0.55-second yellow aim telegraph, then fires one projectile. The elite Stormcaller has a crown/ring silhouette and fires a symmetric three-projectile spread after the same telegraph, proving elite behavior beyond health scaling. Projectiles damage once and expire on impact or outside arena bounds. Fixed loot seeds are `424243` and `424244`.

Defeating all three arena enemies awakens the Abyssal Warden at `(0, 230)`. Phase 1 telegraphs for 0.7 seconds and fires two focused tidal lances. At half health it enters Maelstrom: its silhouette turns magenta, movement pressure increases, telegraph shortens to 0.4 seconds, and its attack becomes an eight-direction radial volley. Verdant Crucible multiplies the active phase speed from its baseline. Victory drops the deterministic legendary Riftwake Core.

Equipping Riftwake Core grants Riftwake Pulse. Every player attack releases a 115-pixel ring for 2 damage after the directional strike. The primary target is excluded; nearby ordinary, elite, boss, and rift enemies can each receive one secondary hit. Pure targeting orders candidates by distance and stable ID before world damage is applied.

Island risk applies from immutable combat baselines. Verdant Crucible multiplies movement by 1.25, Emberglass Reach adds 2 to player attack damage, and Tempest Loom adds 1 damage to every enemy projectile. Replacing or removing a shard clears the prior modifier before applying the new one.
