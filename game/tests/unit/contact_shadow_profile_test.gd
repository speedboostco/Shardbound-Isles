extends RefCounted

const SHADOW_PATH := "res://game/ui/contact_shadow.gd"

func run(support: TestSupport) -> void:
	var Shadow: Variant = load(SHADOW_PATH)
	support.expect(Shadow != null, "shared contact shadow renderer must load")
	if Shadow == null:
		return
	support.expect(Shadow.validate_profiles().is_empty(), "all contact-shadow profiles must remain physically grounded and visually bounded")
	for profile_id: String in ["player", "enemy", "ranged_enemy", "resident", "resource", "obstacle", "living_prop"]:
		var profile: Dictionary = Shadow.profile(profile_id)
		support.expect(float(profile.get("foot_y", 0.0)) > 0.0, "%s shadow must sit at the authored ground contact" % profile_id)
		support.expect(float(profile.get("scale_y", 1.0)) <= 0.22, "%s shadow must be narrow rather than a detached platform" % profile_id)
		support.expect(float(profile.get("opacity", 1.0)) <= 0.24, "%s shadow must support rather than overpower the sprite" % profile_id)
