# Combat

The player uses a short-range directional strike. The red chaser pressures through contact damage.

The Tide Slinger is the second ordinary archetype: it maintains range, displays a 0.55-second yellow aim telegraph, then fires one projectile. The elite Stormcaller has a crown/ring silhouette and fires a symmetric three-projectile spread after the same telegraph, proving elite behavior beyond health scaling. Projectiles damage once and expire on impact or outside arena bounds. Fixed loot seeds are `424243` and `424244`.

Defeating all three arena enemies awakens the Abyssal Warden at `(0, 230)`. Phase 1 telegraphs for 0.7 seconds and fires two focused tidal lances. At half health it enters Maelstrom: its silhouette turns magenta, movement pressure increases, telegraph shortens to 0.4 seconds, and its attack becomes an eight-direction radial volley. Verdant Crucible multiplies the active phase speed from its baseline. Victory drops the deterministic legendary Riftwake Core.

Equipping Riftwake Core grants Riftwake Pulse. Every player attack releases a 115-pixel ring for 2 damage after the directional strike. The primary target is excluded; nearby ordinary, elite, boss, and rift enemies can each receive one secondary hit. Pure targeting orders candidates by distance and stable ID before world damage is applied.
