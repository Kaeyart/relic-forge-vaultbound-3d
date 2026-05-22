class_name RVClassStarterBuildSystem3D
extends RefCounted

const GEM_SYSTEM := preload("res://scripts/systems/SkillGemSystem3D.gd")

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	var materials: Dictionary = _dict(state.get("materials"))
	if not bool(materials.get("_class_starters_seeded_035", false)):
		materials["_class_starters_seeded_035"] = true
		state.set("materials", materials)
		_apply_current_class_starter(state, true)


static func apply_class_starter_for_testing(state: Object, class_id: String) -> String:
	if state == null:
		return "No state."
	state.set("class_id", class_id)
	match class_id:
		"warrior":
			state.set("class_display_name", "Warrior")
		"huntress":
			state.set("class_display_name", "Huntress")
		_:
			state.set("class_display_name", "Sorceress")
	_apply_current_class_starter(state, false)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Starter build applied for " + str(state.get("class_display_name")) + "."


static func _apply_current_class_starter(state: Object, only_if_empty: bool) -> void:
	var class_id: String = str(_state_get(state, "class_id", "sorceress"))
	var page: Array = _array(state.get("equipped_gem_page"))
	var hotbar: Array = _array(state.get("hotbar_slots"))
	if only_if_empty and not _page_empty(page):
		return
	while page.size() < 9:
		page.append({})
	while hotbar.size() < 5:
		hotbar.append("")
	var active_ids: Array[String] = []
	var support_ids: Array[String] = []
	var spirit_id: String = "ember_pact"
	match class_id:
		"warrior":
			active_ids = ["heavy_slam", "ground_rupture", "shield_burst"]
			support_ids = ["brutality", "greater_area", "bleed_edge", "rapid_strikes"]
			spirit_id = "iron_skin"
		"huntress":
			active_ids = ["piercing_shot", "rain_of_arrows", "snare_trap"]
			support_ids = ["pierce", "split_projectile", "chain_current", "rapid_strikes"]
			spirit_id = "predator_focus"
		_:
			active_ids = ["fireball", "storm_lance", "void_rift"]
			support_ids = ["split_projectile", "ignition", "chain_current", "echoing_ritual"]
			spirit_id = "ember_pact"
	for i in range(active_ids.size()):
		var gem: Dictionary = _make_active(active_ids[i], 1)
		page[i] = gem
		if i < hotbar.size():
			hotbar[i] = str(gem.get("uid", ""))
	state.set("equipped_gem_page", page)
	state.set("hotbar_slots", hotbar)
	state.set("selected_gem_uid", str(Dictionary(page[0]).get("uid", "")))
	state.set("selected_hotbar_slot", 0)
	var inventory: Array = _array(state.get("gem_inventory"))
	for support_id: String in support_ids:
		if not _inventory_has(inventory, "support_gem", support_id):
			inventory.append(_make_support(support_id, 1))
	if not _has_uncut(inventory, "uncut_active_gem"):
		inventory.append(_make_uncut("uncut_active_gem", 1))
	if not _has_uncut(inventory, "uncut_support_gem"):
		inventory.append(_make_uncut("uncut_support_gem", 1))
	if not _has_uncut(inventory, "uncut_spirit_gem"):
		inventory.append(_make_uncut("uncut_spirit_gem", 1))
	state.set("gem_inventory", inventory)
	var spirits: Array = _array(state.get("spirit_gem_slots"))
	if not _spirit_has(spirits, spirit_id):
		spirits.append(_make_spirit(spirit_id, 1))
	state.set("spirit_gem_slots", spirits)
	if state.has_method("add_notice"):
		state.call("add_notice", "Starter build applied: " + str(_state_get(state, "class_display_name", class_id)))

static func _make_active(gem_id: String, level: int) -> Dictionary:
	var uid: String = "active_" + gem_id + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000)
	return {
		"uid": uid,
		"kind": "active_gem",
		"gem_id": gem_id,
		"level": level,
		"xp": 0,
		"quality": 0,
		"support_socket_count": 2,
		"support_sockets": [null, null],
		"enabled": true,
	}


static func _make_support(gem_id: String, level: int) -> Dictionary:
	return {"uid": "support_" + gem_id + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000), "kind": "support_gem", "gem_id": gem_id, "level": level, "quality": 0, "equipped_to": ""}


static func _make_spirit(gem_id: String, level: int) -> Dictionary:
	return {"uid": "spirit_" + gem_id + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000), "kind": "spirit_gem", "gem_id": gem_id, "level": level, "quality": 0, "enabled": false, "reservation": 30, "support_socket_count": 2, "support_sockets": [null, null]}


static func _make_uncut(kind: String, level: int) -> Dictionary:
	return {"uid": kind + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000), "kind": kind, "gem_level": level, "gem_tier": level, "level": level, "can_create": kind.replace("uncut_", "").replace("_gem", "")}


static func _page_empty(page: Array) -> bool:
	for value: Variant in page:
		if typeof(value) == TYPE_DICTIONARY and not Dictionary(value).is_empty():
			return false
	return true


static func _inventory_has(inventory: Array, kind_value: String, gem_id: String) -> bool:
	for value: Variant in inventory:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("kind", "")) == kind_value and str(Dictionary(value).get("gem_id", "")) == gem_id:
			return true
	return false


static func _has_uncut(inventory: Array, kind_value: String) -> bool:
	for value: Variant in inventory:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("kind", "")) == kind_value:
			return true
	return false


static func _spirit_has(spirits: Array, gem_id: String) -> bool:
	for value: Variant in spirits:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("gem_id", "")) == gem_id:
			return true
	return false


static func _array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []


static func _dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value
