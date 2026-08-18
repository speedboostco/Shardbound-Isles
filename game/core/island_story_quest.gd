class_name IslandStoryQuest
extends RefCounted

const RngStreams := preload("res://game/core/seeded_rng_streams.gd")

const STATUSES: Array[String] = ["locked", "offered", "active", "completed", "claimed"]
const BRANCHES: Array[String] = ["restoration", "purge"]
const SURVEY_STAGE: int = 0
const BRANCH_STAGE: int = 1
const WARDEN_STAGE: int = 2
const BIOME_CONTENT: Dictionary = {
	"forest": {"region": "Verdant Crucible", "survey_event": "grove_echo", "restoration_event": "root_bond", "purge_event": "thorn_nest", "warden_name": "Verdant Warden"},
	"swamp": {"region": "Sporefen Mire", "survey_event": "mire_lantern", "restoration_event": "spore_bloom", "purge_event": "blight_nest", "warden_name": "Sporebound Warden"},
	"volcano": {"region": "Emberglass Reach", "survey_event": "magma_rune", "restoration_event": "vent_seal", "purge_event": "cinder_nest", "warden_name": "Emberglass Warden"},
	"frozen": {"region": "Tempest Loom", "survey_event": "frost_beacon", "restoration_event": "conduit_link", "purge_event": "rime_nest", "warden_name": "Tempest Warden"},
	"graveyard": {"region": "Hollow Rest", "survey_event": "memory_lantern", "restoration_event": "spirit_bond", "purge_event": "haunt_nest", "warden_name": "Hollow Warden"},
	"settlement": {"region": "Lantern Haven", "survey_event": "maker_sign", "restoration_event": "workshop_link", "purge_event": "raider_cache", "warden_name": "Lantern Warden"},
}

var definition: Dictionary = {}
var status: String = "locked"
var stage: int = SURVEY_STAGE
var branch: String = ""
var progress: int = 0
var claimed_event_ids: Array[String] = []
var purchased_offer_ids: Array[String] = []

static func generate(slot_id: String, shard: Dictionary) -> Dictionary:
	if slot_id.is_empty() or not IslandShardDefinition.validate_dictionary(shard).is_empty():
		return {}
	var biome := String(shard.biome).to_lower()
	if biome not in BIOME_CONTENT:
		return {}
	var content := BIOME_CONTENT[biome] as Dictionary
	var island_seed := int(shard.seed)
	var reward_rng := RngStreams.from_seed(RngStreams.derive_seed(island_seed, "island_story:%s" % slot_id))
	return {
		"quest_id": "tala_%s_%s" % [slot_id, String(shard.shard_id)],
		"issuer_id": "tala",
		"issuer_name": "Tala",
		"slot_id": slot_id,
		"island_id": String(shard.shard_id),
		"island_seed": island_seed,
		"biome": biome,
		"level": int(shard.level),
		"title": "Echoes of %s" % String(content.region),
		"region_name": String(content.region),
		"survey_event": String(content.survey_event),
		"restoration_event": String(content.restoration_event),
		"purge_event": String(content.purge_event),
		"warden_name": String(content.warden_name),
		"reward_seeds": {
			"equipment": reward_rng.randi_range(100000, 999999),
			"island_shard": reward_rng.randi_range(10000, 99999),
		},
	}

static func validate_definition(value: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var required_strings: Array[String] = ["quest_id", "issuer_id", "issuer_name", "slot_id", "island_id", "biome", "title", "region_name", "survey_event", "restoration_event", "purge_event", "warden_name"]
	for key: String in required_strings:
		if not value.get(key) is String or String(value.get(key, "")).is_empty():
			errors.append("%s must be a non-empty string" % key)
	if String(value.get("biome", "")) not in BIOME_CONTENT:
		errors.append("unsupported story biome")
	for key: String in ["island_seed", "level"]:
		if not (value.get(key) is int or value.get(key) is float) or int(value.get(key, 0)) <= 0:
			errors.append("%s must be positive" % key)
	if not value.get("reward_seeds") is Dictionary:
		errors.append("reward seeds must be a dictionary")
	else:
		var seeds := value.reward_seeds as Dictionary
		for key: String in ["equipment", "island_shard"]:
			if not (seeds.get(key) is int or seeds.get(key) is float) or int(seeds.get(key, 0)) <= 0:
				errors.append("reward seed %s must be positive" % key)
	return errors

func bind_island(slot_id: String, shard: Dictionary) -> bool:
	var generated := generate(slot_id, shard)
	if generated.is_empty():
		return false
	if String(definition.get("quest_id", "")) == String(generated.quest_id):
		return false
	definition = generated
	status = "offered"
	stage = SURVEY_STAGE
	branch = ""
	progress = 0
	claimed_event_ids.clear()
	purchased_offer_ids.clear()
	return true

func accept() -> bool:
	if status != "offered":
		return false
	status = "active"
	return true

func choose_branch(branch_id: String) -> bool:
	if status != "active" or stage != BRANCH_STAGE or not branch.is_empty() or branch_id not in BRANCHES:
		return false
	branch = branch_id
	progress = 0
	return true

func record(objective_kind: String, amount: int = 1, event_id: String = "") -> Dictionary:
	var rejected := {"accepted": false, "stage_advanced": false, "completed_now": false, "progress": progress}
	if status != "active" or amount <= 0 or objective_kind != current_objective_kind():
		return rejected
	if not event_id.is_empty():
		if event_id in claimed_event_ids:
			return rejected
		claimed_event_ids.append(event_id)
	var target := current_target()
	progress = mini(target, progress + amount)
	if progress < target:
		return {"accepted": true, "stage_advanced": false, "completed_now": false, "progress": progress}
	if stage < WARDEN_STAGE:
		stage += 1
		progress = 0
		return {"accepted": true, "stage_advanced": true, "completed_now": false, "progress": progress}
	status = "completed"
	return {"accepted": true, "stage_advanced": false, "completed_now": true, "progress": progress}

func current_objective_kind() -> String:
	if status != "active":
		return ""
	if stage == SURVEY_STAGE:
		return "survey_site"
	if stage == BRANCH_STAGE:
		if branch == "restoration":
			return "restoration_site"
		if branch == "purge":
			return "purge_site"
		return ""
	if stage == WARDEN_STAGE:
		return "warden_defeated"
	return ""

func current_target() -> int:
	return 1 if stage == WARDEN_STAGE else 2

func current_event_type() -> String:
	if definition.is_empty():
		return ""
	if stage == SURVEY_STAGE:
		return String(definition.survey_event)
	if stage == BRANCH_STAGE and branch == "restoration":
		return String(definition.restoration_event)
	if stage == BRANCH_STAGE and branch == "purge":
		return String(definition.purge_event)
	return ""

func claim() -> Dictionary:
	if status != "completed" or branch not in BRANCHES:
		return {"success": false, "reward": {}}
	status = "claimed"
	var seeds := definition.reward_seeds as Dictionary
	var reward := {
		"expedition_marks": 2,
		"kind": "island_shard" if branch == "restoration" else "equipment",
		"seed": int(seeds.island_shard if branch == "restoration" else seeds.equipment),
		"level": maxi(1, int(definition.level) + (1 if branch == "restoration" else 0)),
	}
	return {"success": true, "reward": reward}

func vendor_unlocked() -> bool:
	return status == "claimed"

static func vendor_catalog() -> Array[Dictionary]:
	return [
		{"id": "wayfinder_cache", "name": "Wayfinder Cache", "cost": 1, "kind": "equipment", "description": "Seeded rare equipment tuned to the island level."},
		{"id": "focused_shard", "name": "Focused Shard", "cost": 2, "kind": "island_shard", "description": "A new island shard one level above Tala's island."},
		{"id": "field_supplies", "name": "Field Supplies", "cost": 1, "kind": "resource", "resource_id": "moonleaf", "amount": 3, "description": "Three Moonleaf delivered through the ordinary pickup flow."},
	]

static func plan_purchase(offer_id: String, available_marks: int) -> Dictionary:
	for offer: Dictionary in vendor_catalog():
		if String(offer.id) != offer_id:
			continue
		var cost := int(offer.cost)
		if available_marks < cost:
			return {"success": false, "reason": "insufficient_marks", "cost": cost, "reward": {}}
		return {"success": true, "reason": "", "cost": cost, "reward": offer.duplicate(true)}
	return {"success": false, "reason": "unknown_offer", "cost": 0, "reward": {}}

func mark_offer_purchased(offer_id: String) -> bool:
	if not vendor_unlocked() or offer_id in purchased_offer_ids or vendor_catalog().all(func(offer: Dictionary) -> bool: return String(offer.id) != offer_id):
		return false
	purchased_offer_ids.append(offer_id)
	return true

func offer_purchased(offer_id: String) -> bool:
	return offer_id in purchased_offer_ids

func objective_text() -> String:
	if status == "locked" or definition.is_empty():
		return "INSTALL AN ISLAND TO BEGIN TALA'S STORY"
	if status == "offered":
		return "TALA HAS AN ISLAND STORY"
	if status == "completed":
		return "STORY COMPLETE  •  RETURN TO TALA"
	if status == "claimed":
		return "TALA'S EXCHANGE UNLOCKED"
	if stage == SURVEY_STAGE:
		return "SURVEY %s  %d/%d" % [String(definition.region_name).to_upper(), progress, current_target()]
	if stage == BRANCH_STAGE and branch.is_empty():
		return "RETURN TO TALA  •  CHOOSE RESTORATION OR PURGE"
	if stage == BRANCH_STAGE:
		return "%s THE %s  %d/%d" % ["RESTORE" if branch == "restoration" else "PURGE", String(definition.region_name).to_upper(), progress, current_target()]
	return "DEFEAT THE %s  %d/%d" % [String(definition.warden_name).to_upper(), progress, current_target()]

func to_dictionary() -> Dictionary:
	return {
		"definition": definition.duplicate(true),
		"status": status,
		"stage": stage,
		"branch": branch,
		"progress": progress,
		"claimed_event_ids": claimed_event_ids.duplicate(),
		"purchased_offer_ids": purchased_offer_ids.duplicate(),
	}

func restore(data: Dictionary) -> bool:
	if not data.get("definition") is Dictionary or not data.get("status") is String or not (data.get("stage") is int or data.get("stage") is float) or not data.get("branch") is String or not (data.get("progress") is int or data.get("progress") is float) or not data.get("claimed_event_ids") is Array or not data.get("purchased_offer_ids") is Array:
		return false
	var saved_definition := data.definition as Dictionary
	var saved_status := String(data.status)
	var saved_stage := int(data.stage)
	var saved_branch := String(data.branch)
	var saved_progress := int(data.progress)
	if saved_status not in STATUSES or saved_stage < SURVEY_STAGE or saved_stage > WARDEN_STAGE or saved_progress < 0:
		return false
	if saved_status == "locked":
		if not saved_definition.is_empty() or saved_stage != SURVEY_STAGE or not saved_branch.is_empty() or saved_progress != 0:
			return false
	else:
		if not validate_definition(saved_definition).is_empty():
			return false
		if saved_branch not in BRANCHES and not saved_branch.is_empty():
			return false
		if saved_stage == SURVEY_STAGE and not saved_branch.is_empty():
			return false
		if saved_stage == BRANCH_STAGE and saved_branch.is_empty() and saved_progress != 0:
			return false
		var target := 1 if saved_stage == WARDEN_STAGE else 2
		if saved_progress > target:
			return false
		if saved_status in ["offered", "active"] and saved_progress >= target:
			return false
		if saved_status in ["completed", "claimed"] and (saved_stage != WARDEN_STAGE or saved_progress != 1 or saved_branch not in BRANCHES):
			return false
	var normalized_tokens: Array[String] = []
	for token_value: Variant in data.claimed_event_ids:
		if not token_value is String or String(token_value).is_empty() or String(token_value) in normalized_tokens:
			return false
		normalized_tokens.append(String(token_value))
	var normalized_purchases: Array[String] = []
	var valid_offers: Array[String] = []
	for offer: Dictionary in vendor_catalog():
		valid_offers.append(String(offer.id))
	for offer_value: Variant in data.purchased_offer_ids:
		if not offer_value is String or String(offer_value) not in valid_offers or String(offer_value) in normalized_purchases or saved_status != "claimed":
			return false
		normalized_purchases.append(String(offer_value))
	definition = saved_definition.duplicate(true)
	if not definition.is_empty():
		definition["island_seed"] = int(definition.island_seed)
		definition["level"] = int(definition.level)
		var seeds := (definition.reward_seeds as Dictionary).duplicate(true)
		seeds["equipment"] = int(seeds.equipment)
		seeds["island_shard"] = int(seeds.island_shard)
		definition["reward_seeds"] = seeds
	status = saved_status
	stage = saved_stage
	branch = saved_branch
	progress = saved_progress
	claimed_event_ids = normalized_tokens
	purchased_offer_ids = normalized_purchases
	return true

static func default_state() -> Dictionary:
	return {"definition": {}, "status": "locked", "stage": SURVEY_STAGE, "branch": "", "progress": 0, "claimed_event_ids": [], "purchased_offer_ids": []}
