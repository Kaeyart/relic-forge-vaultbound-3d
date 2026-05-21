extends RefCounted
class_name RVFinalUIActions3D

const SchemaScript := preload("res://scripts/systems/FinalUISchema3D.gd")
const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")
const CraftingSystemScript := preload("res://scripts/systems/CraftingSystem3D.gd")

static func perform(state: Object, action: String, context: Dictionary = {}) -> String:
	if state == null:
		return "No game state."

	match action:
		"close":
			state.set("panel_mode", "")
			return "Closed panel."
		"sort":
			return _sort_inventory_or_maps(state, context)
		"equip":
			return _equip_selected(state)
		"compare":
			return "Comparison shown in details panel."
		"stash":
			return _stash_selected(state)
		"salvage":
			return _salvage_selected(state)
		"cut_gem":
			return cut_selected_uncut_gem(state, context)
		"install":
			return cut_selected_uncut_gem(state, context)
		"add_support":
			return cut_selected_uncut_gem(state, {"force_kind":"support"})
		"toggle_spirit":
			return toggle_selected_spirit(state, context)
		"remove":
			return remove_selected_gem(state, context)
		"seal":
			return _craft(state, "seal")
		"reforge":
			return _craft(state, "reforge")
		"polish":
			return _craft(state, "polish")
		"upgrade":
			return _craft(state, "upgrade")
		"remove_affix":
			return _craft(state, "remove")
		"deposit_all":
			return quick_deposit_all(state)
		"withdraw":
			return "Select a stash item to withdraw."
		"buy_tab":
			return buy_generic_stash_tab(state)
		"search":
			return "Type in the search box."
		"open_map":
			return open_selected_map(state)
		"take_all":
			return take_all_rewards(state)
		"inspect":
			return "Select a reward to inspect."
		"return_hub":
			state.set("mode", "hub")
			return "Returned to hub."
		_:
			return "Action not wired: " + action


static func cut_selected_uncut_gem(state: Object, context: Dictionary = {}) -> String:
	var backpack: Array = _state_array(state, "backpack")
	var selected_index: int = clampi(_state_int(state, "inventory_cursor", 0), 0, max(0, backpack.size() - 1))
	if backpack.is_empty() or selected_index >= backpack.size() or typeof(backpack[selected_index]) != TYPE_DICTIONARY:
		return "Select an uncut gem in inventory."

	var item: Dictionary = Dictionary(backpack[selected_index])
	var forced: String = str(context.get("force_kind", ""))
	var gem_kind: String = _uncut_gem_kind(item)
	if forced != "" and gem_kind != forced:
		return "Selected gem is not an uncut " + forced + " gem."
	if gem_kind == "":
		return "Selected item is not an uncut gem."

	if gem_kind == "active":
		return _cut_active_gem(state, backpack, selected_index)
	if gem_kind == "support":
		return _cut_support_gem(state, backpack, selected_index)
	if gem_kind == "spirit":
		return _cut_spirit_gem(state, backpack, selected_index)

	return "Unknown uncut gem kind."


static func toggle_selected_spirit(state: Object, context: Dictionary = {}) -> String:
	var spirits: Array = _state_array(state, "installed_spirit_gems")
	if spirits.is_empty():
		return "No spirit gems installed."

	var index: int = clampi(_state_int(state, "selected_spirit_index", 0), 0, spirits.size() - 1)
	if typeof(spirits[index]) != TYPE_DICTIONARY:
		return "Invalid spirit gem."

	var spirit: Dictionary = Dictionary(spirits[index])
	var enabled: bool = not bool(spirit.get("enabled", false))
	spirit["enabled"] = enabled
	spirits[index] = spirit
	state.set("installed_spirit_gems", spirits)
	_recompute_spirit(state)

	return str(spirit.get("label", "Spirit")) + (" enabled." if enabled else " disabled.")


static func remove_selected_gem(state: Object, context: Dictionary = {}) -> String:
	var selected_skill: int = _state_int(state, "selected_skill_index", 0)
	var active: Array = _state_array(state, "installed_active_gems")
	if selected_skill >= 0 and selected_skill < active.size():
		var stored: Array = _state_array(state, "cut_gem_storage")
		stored.append(active[selected_skill])
		active.remove_at(selected_skill)
		state.set("installed_active_gems", active)
		state.set("cut_gem_storage", stored)
		return "Removed skill to cut gem storage."
	return "No removable skill selected."


static func quick_deposit_all(state: Object) -> String:
	var backpack: Array = _state_array(state, "backpack")
	if backpack.is_empty():
		return "Backpack is empty."

	_ensure_stash_defaults(state)
	var tabs: Array = _state_array(state, "final_stash_tabs")
	var remaining: Array = []
	var deposited: int = 0

	for value: Variant in backpack:
		if typeof(value) != TYPE_DICTIONARY:
			remaining.append(value)
			continue
		var item: Dictionary = Dictionary(value)
		var tab_index: int = _route_stash_tab(tabs, item)
		if tab_index < 0:
			remaining.append(item)
			continue
		var tab: Dictionary = Dictionary(tabs[tab_index])
		var items: Array = _dict_array(tab, "items")
		items.append(item)
		tab["items"] = items
		tabs[tab_index] = tab
		deposited += 1

	state.set("backpack", remaining)
	state.set("final_stash_tabs", tabs)
	return "Deposited " + str(deposited) + " items."


static func buy_generic_stash_tab(state: Object) -> String:
	_ensure_stash_defaults(state)
	var gold: int = _state_int(state, "gold", 0)
	var cost: int = 250
	if gold < cost:
		return "Need " + str(cost) + " gold."

	var tabs: Array = _state_array(state, "final_stash_tabs")
	var count: int = 1
	for value: Variant in tabs:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("kind", "")) == "gear":
			count += 1

	tabs.append({"id":"gear_" + str(count), "label":"Gear Tab " + str(count), "kind":"gear", "items":[]})
	state.set("final_stash_tabs", tabs)
	state.set("gold", gold - cost)
	return "Bought Gear Tab " + str(count) + "."


static func open_selected_map(state: Object) -> String:
	var map_item: Dictionary = _selected_map(state)
	if map_item.is_empty():
		return "No map selected."

	state.set("current_map_activity", map_item.duplicate(true))
	state.set("active_map_item", map_item.duplicate(true))
	state.set("mode", "combat")
	state.set("panel_mode", "")
	return "Opened " + str(map_item.get("display_name", "Map")) + "."


static func take_all_rewards(state: Object) -> String:
	var rewards: Array = _state_array(state, "pending_rewards")
	if rewards.is_empty():
		return "No pending rewards."

	var backpack: Array = _state_array(state, "backpack")
	for value: Variant in rewards:
		backpack.append(value)
	state.set("backpack", backpack)
	state.set("pending_rewards", [])
	return "Took " + str(rewards.size()) + " rewards."


static func describe_item(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."

	return _generic_item_text(item)


static func compare_selected_text(state: Object, item: Dictionary) -> String:
	if item.is_empty() or not _looks_like_item(item):
		return ""

	var equipped: Dictionary = _state_dict(state, "equipped")
	var slot: String = str(item.get("slot", ""))
	var current: Dictionary = {}

	if equipped.has(slot) and typeof(equipped[slot]) == TYPE_DICTIONARY:
		current = Dictionary(equipped[slot])
	elif slot == "ring" and equipped.has("ring_1") and typeof(equipped["ring_1"]) == TYPE_DICTIONARY:
		current = Dictionary(equipped["ring_1"])

	if current.is_empty():
		return "No equipped item in this slot."

	return _compare_items_text(item, current)
	


static func _cut_active_gem(state: Object, backpack: Array, selected_index: int) -> String:
	var choices: Array[Dictionary] = SchemaScript.active_skill_choices()
	var choice_index: int = clampi(_state_int(state, "cut_active_choice_index", 0), 0, choices.size() - 1)
	var choice: Dictionary = choices[choice_index]

	var active: Array = _state_array(state, "installed_active_gems")
	active.append({
		"id": str(choice.get("id", "fireball")),
		"label": str(choice.get("label", "Fireball")),
		"level": 1,
		"xp": 0,
		"quality": 0,
		"sockets_unlocked": 2,
		"supports": [],
		"tags": str(choice.get("tags", "")),
	})
	backpack.remove_at(selected_index)
	state.set("backpack", backpack)
	state.set("installed_active_gems", active)
	state.set("selected_skill_index", max(0, active.size() - 1))
	return "Cut active gem into " + str(choice.get("label", "Skill")) + "."


static func _cut_support_gem(state: Object, backpack: Array, selected_index: int) -> String:
	var active: Array = _state_array(state, "installed_active_gems")
	var spirits: Array = _state_array(state, "installed_spirit_gems")
	if active.is_empty() and spirits.is_empty():
		return "Install an active or spirit skill first."

	var choices: Array[Dictionary] = SchemaScript.support_choices()
	var choice_index: int = clampi(_state_int(state, "cut_support_choice_index", 0), 0, choices.size() - 1)
	var support: Dictionary = choices[choice_index].duplicate(true)
	support["level"] = 1
	support["quality"] = 0

	var target_type_value: Variant = state.get("support_target_type")
	var target_type: String = "" if target_type_value == null else str(target_type_value)
	if target_type == "":
		target_type = "active"

	if target_type == "spirit" and not spirits.is_empty():
		var spirit_index: int = clampi(_state_int(state, "selected_spirit_index", 0), 0, spirits.size() - 1)
		var spirit: Dictionary = Dictionary(spirits[spirit_index])
		var supports: Array = _dict_array(spirit, "supports")
		supports.append(support)
		spirit["supports"] = supports
		spirits[spirit_index] = spirit
		state.set("installed_spirit_gems", spirits)
	else:
		var skill_index: int = clampi(_state_int(state, "selected_skill_index", 0), 0, active.size() - 1)
		var skill: Dictionary = Dictionary(active[skill_index])
		var supports2: Array = _dict_array(skill, "supports")
		var unlocked: int = int(skill.get("sockets_unlocked", 2))
		if supports2.size() >= unlocked:
			return "Selected skill has no open support socket."
		supports2.append(support)
		skill["supports"] = supports2
		active[skill_index] = skill
		state.set("installed_active_gems", active)

	backpack.remove_at(selected_index)
	state.set("backpack", backpack)
	return "Cut support gem into " + str(support.get("label", "Support")) + "."


static func _cut_spirit_gem(state: Object, backpack: Array, selected_index: int) -> String:
	var choices: Array[Dictionary] = SchemaScript.spirit_choices()
	var choice_index: int = clampi(_state_int(state, "cut_spirit_choice_index", 0), 0, choices.size() - 1)
	var choice: Dictionary = choices[choice_index]

	var spirits: Array = _state_array(state, "installed_spirit_gems")
	spirits.append({
		"id": str(choice.get("id", "ember_pact")),
		"label": str(choice.get("label", "Ember Pact")),
		"level": 1,
		"xp": 0,
		"quality": 0,
		"reserve": int(choice.get("reserve", 20)),
		"effect": str(choice.get("effect", "")),
		"enabled": false,
		"supports": [],
	})
	backpack.remove_at(selected_index)
	state.set("backpack", backpack)
	state.set("installed_spirit_gems", spirits)
	state.set("selected_spirit_index", max(0, spirits.size() - 1))
	_recompute_spirit(state)
	return "Cut spirit gem into " + str(choice.get("label", "Spirit")) + "."


static func _recompute_spirit(state: Object) -> void:
	var spirits: Array = _state_array(state, "installed_spirit_gems")
	var reserved: int = 0
	for value: Variant in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit: Dictionary = Dictionary(value)
		if bool(spirit.get("enabled", false)):
			reserved += int(spirit.get("reserve", 0))
	state.set("spirit_reserved", reserved)
	if state.get("spirit_max") == null:
		state.set("spirit_max", 60)


static func _equip_selected(state: Object) -> String:
	var backpack: Array = _state_array(state, "backpack")
	if backpack.is_empty():
		return "Backpack empty."
	var index: int = clampi(_state_int(state, "inventory_cursor", 0), 0, backpack.size() - 1)
	if typeof(backpack[index]) != TYPE_DICTIONARY:
		return "Selected item invalid."

	var item: Dictionary = Dictionary(backpack[index])
	if not _looks_like_item(item):
		return "Selected item cannot be equipped."

	var slot: String = str(item.get("slot", ""))
	if slot == "ring":
		slot = "ring_1"
	if slot == "":
		return "Item has no equipment slot."

	var equipped: Dictionary = _state_dict(state, "equipped")
	if equipped.has(slot) and typeof(equipped[slot]) == TYPE_DICTIONARY:
		backpack[index] = equipped[slot]
	else:
		backpack.remove_at(index)

	equipped[slot] = item
	state.set("equipped", equipped)
	state.set("backpack", backpack)

	if state.has_method("recompute_stats"):
		state.call("recompute_stats")

	return "Equipped " + str(item.get("display_name", item.get("base_name", "Item"))) + "."


static func _stash_selected(state: Object) -> String:
	var backpack: Array = _state_array(state, "backpack")
	if backpack.is_empty():
		return "Backpack empty."
	var index: int = clampi(_state_int(state, "inventory_cursor", 0), 0, backpack.size() - 1)
	if typeof(backpack[index]) != TYPE_DICTIONARY:
		return "Selected item invalid."

	_ensure_stash_defaults(state)
	var tabs: Array = _state_array(state, "final_stash_tabs")
	var item: Dictionary = Dictionary(backpack[index])
	var tab_index: int = _route_stash_tab(tabs, item)
	if tab_index < 0:
		return "No stash tab can accept this item."

	var tab: Dictionary = Dictionary(tabs[tab_index])
	var items: Array = _dict_array(tab, "items")
	items.append(item)
	tab["items"] = items
	tabs[tab_index] = tab
	backpack.remove_at(index)
	state.set("backpack", backpack)
	state.set("final_stash_tabs", tabs)
	return "Stashed item."


static func _salvage_selected(state: Object) -> String:
	var backpack: Array = _state_array(state, "backpack")
	if backpack.is_empty():
		return "Backpack empty."
	var index: int = clampi(_state_int(state, "inventory_cursor", 0), 0, backpack.size() - 1)
	if typeof(backpack[index]) != TYPE_DICTIONARY:
		return "Selected item invalid."

	backpack.remove_at(index)
	state.set("backpack", backpack)

	var materials: Dictionary = _state_dict(state, "materials")
	materials["shards"] = int(materials.get("shards", 0)) + 1
	state.set("materials", materials)
	return "Salvaged item into shards."


static func _sort_inventory_or_maps(state: Object, context: Dictionary) -> String:
	var mode: String = str(context.get("mode", "inventory"))
	if mode == "maps":
		var maps: Array = _state_array(state, "map_stash")
		maps.sort_custom(func(a: Variant, b: Variant) -> bool:
			if typeof(a) != TYPE_DICTIONARY or typeof(b) != TYPE_DICTIONARY:
				return false
			var da: Dictionary = Dictionary(a)
			var db: Dictionary = Dictionary(b)
			return int(da.get("tier", da.get("map_tier", 1))) < int(db.get("tier", db.get("map_tier", 1)))
		)
		state.set("map_stash", maps)
		return "Sorted maps."

	var backpack: Array = _state_array(state, "backpack")
	backpack.sort_custom(func(a: Variant, b: Variant) -> bool:
		if typeof(a) != TYPE_DICTIONARY or typeof(b) != TYPE_DICTIONARY:
			return false
		return _sort_key(Dictionary(a)) < _sort_key(Dictionary(b))
	)
	state.set("backpack", backpack)
	return "Sorted inventory."


static func _craft(state: Object, action: String) -> String:
	var ok: bool = CraftingSystemScript.craft_selected(state, action)
	return "Forge applied: " + action if ok else "Forge failed: " + action


static func _selected_map(state: Object) -> Dictionary:
	var maps: Array = _state_array(state, "map_stash")
	if maps.is_empty():
		return {}
	var index: int = clampi(_state_int(state, "map_cursor", 0), 0, maps.size() - 1)
	if typeof(maps[index]) == TYPE_DICTIONARY:
		return Dictionary(maps[index])
	return {}


static func _ensure_stash_defaults(state: Object) -> void:
	var tabs: Array = _state_array(state, "final_stash_tabs")
	if not tabs.is_empty():
		return
	tabs = [
		{"id":"currency", "label":"Currency", "kind":"currency", "items":[]},
		{"id":"maps", "label":"Maps", "kind":"maps", "items":[]},
		{"id":"gems", "label":"Gems", "kind":"gems", "items":[]},
		{"id":"crystals", "label":"Crystals", "kind":"crystals", "items":[]},
		{"id":"uniques", "label":"Uniques", "kind":"uniques", "items":[]},
		{"id":"gear_1", "label":"Gear Tab 1", "kind":"gear", "items":[]},
	]
	state.set("final_stash_tabs", tabs)


static func _route_stash_tab(tabs: Array, item: Dictionary) -> int:
	var kind: String = _item_kind(item)
	for i: int in range(tabs.size()):
		if typeof(tabs[i]) != TYPE_DICTIONARY:
			continue
		var tab: Dictionary = Dictionary(tabs[i])
		var tab_kind: String = str(tab.get("kind", ""))
		if kind == tab_kind:
			return i
		if kind == "gear" and tab_kind == "gear":
			return i
	return -1


static func _item_kind(item: Dictionary) -> String:
	var rarity: String = str(item.get("rarity", "")).to_lower()
	if rarity == "unique":
		return "uniques"

	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	var slot: String = str(item.get("slot", "")).to_lower()

	if kind.find("currency") >= 0 or kind == "material":
		return "currency"
	if kind.find("map") >= 0 or slot == "map":
		return "maps"
	if kind.find("gem") >= 0 or kind.find("uncut") >= 0 or _uncut_gem_kind(item) != "":
		return "gems"
	if kind.find("crystal") >= 0 or str(item.get("material_id", "")).find("crystal") >= 0:
		return "crystals"
	return "gear"

static func _compare_items_text(candidate: Dictionary, equipped: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()

	lines.append("COMPARE")
	lines.append("New: " + str(candidate.get("display_name", candidate.get("name", "Item"))))
	lines.append("Old: " + str(equipped.get("display_name", equipped.get("name", "Item"))))
	lines.append("")

	var candidate_power: int = _item_power(candidate)
	var equipped_power: int = _item_power(equipped)
	var delta_power: int = candidate_power - equipped_power

	lines.append("Power: " + str(candidate_power) + "  (" + _signed_int(delta_power) + ")")

	var candidate_stats: Dictionary = _extract_stat_map(candidate)
	var equipped_stats: Dictionary = _extract_stat_map(equipped)

	var keys: Array[String] = []
	for key: Variant in candidate_stats.keys():
		var stat_key: String = str(key)
		if not keys.has(stat_key):
			keys.append(stat_key)

	for key: Variant in equipped_stats.keys():
		var stat_key: String = str(key)
		if not keys.has(stat_key):
			keys.append(stat_key)

	if keys.is_empty():
		lines.append("No comparable explicit stats.")
	else:
		lines.append("")
		lines.append("Stat changes:")
		for stat_key: String in keys:
			var new_value: float = float(candidate_stats.get(stat_key, 0.0))
			var old_value: float = float(equipped_stats.get(stat_key, 0.0))
			var delta: float = new_value - old_value

			if absf(delta) <= 0.001:
				continue

			lines.append("• " + stat_key + ": " + _signed_float(delta))

	return "\n".join(lines)
	
static func _item_power(item: Dictionary) -> int:
	if item.has("item_power"):
		return int(item.get("item_power", 0))
	if item.has("power"):
		return int(item.get("power", 0))
	if item.has("level"):
		return int(item.get("level", 1))
	if item.has("item_level"):
		return int(item.get("item_level", 1))
	return 0


static func _extract_stat_map(item: Dictionary) -> Dictionary:
	var out: Dictionary = {}

	if item.has("stats") and typeof(item["stats"]) == TYPE_DICTIONARY:
		for key: Variant in Dictionary(item["stats"]).keys():
			out[str(key)] = float(Dictionary(item["stats"])[key])

	if item.has("implicit_stats") and typeof(item["implicit_stats"]) == TYPE_DICTIONARY:
		for key: Variant in Dictionary(item["implicit_stats"]).keys():
			out[str(key)] = float(out.get(str(key), 0.0)) + float(Dictionary(item["implicit_stats"])[key])

	if item.has("explicit_stats") and typeof(item["explicit_stats"]) == TYPE_DICTIONARY:
		for key: Variant in Dictionary(item["explicit_stats"]).keys():
			out[str(key)] = float(out.get(str(key), 0.0)) + float(Dictionary(item["explicit_stats"])[key])

	if item.has("affixes") and typeof(item["affixes"]) == TYPE_ARRAY:
		for affix_value: Variant in Array(item["affixes"]):
			if typeof(affix_value) != TYPE_DICTIONARY:
				continue

			var affix: Dictionary = Dictionary(affix_value)
			var stat_name: String = str(affix.get("stat", affix.get("stat_key", affix.get("id", ""))))
			if stat_name == "":
				continue

			var value: float = float(affix.get("value", affix.get("amount", 0.0)))
			out[stat_name] = float(out.get(stat_name, 0.0)) + value

	return out


static func _signed_int(value: int) -> String:
	if value > 0:
		return "+" + str(value)
	return str(value)


static func _signed_float(value: float) -> String:
	var rounded_value: float = snappedf(value, 0.01)
	if rounded_value > 0.0:
		return "+" + str(rounded_value)
	return str(rounded_value)

static func _uncut_gem_kind(item: Dictionary) -> String:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	var gem_kind: String = str(item.get("gem_kind", item.get("gem_type", ""))).to_lower()
	var name: String = str(item.get("display_name", item.get("name", ""))).to_lower()

	if kind.find("uncut_active") >= 0 or (gem_kind == "active" and name.find("uncut") >= 0) or name.find("uncut active") >= 0:
		return "active"
	if kind.find("uncut_support") >= 0 or (gem_kind == "support" and name.find("uncut") >= 0) or name.find("uncut support") >= 0:
		return "support"
	if kind.find("uncut_spirit") >= 0 or (gem_kind == "spirit" and name.find("uncut") >= 0) or name.find("uncut spirit") >= 0:
		return "spirit"
	if kind == "active_gem_uncut":
		return "active"
	if kind == "support_gem_uncut":
		return "support"
	if kind == "spirit_gem_uncut":
		return "spirit"
	return ""


static func _looks_like_item(item: Dictionary) -> bool:
	return item.has("slot") or item.has("prefixes") or item.has("suffixes") or item.has("implicit_stats") or str(item.get("item_kind", "")) == "gear"


static func _generic_item_text(item: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append(str(item.get("display_name", item.get("name", item.get("label", "Item")))))
	lines.append("Kind: " + _item_kind(item).capitalize())

	if _uncut_gem_kind(item) != "":
		lines.append("Uncut " + _uncut_gem_kind(item).capitalize() + " Gem")
		lines.append("Use Cut Gem to choose what it becomes.")

	if item.has("amount"):
		lines.append("Amount: " + str(item.get("amount", 1)))

	return "\n".join(lines)


static func _sort_key(item: Dictionary) -> String:
	var kind: String = _item_kind(item)
	var rarity: String = str(item.get("rarity", "normal"))
	var name: String = str(item.get("display_name", item.get("name", "")))
	return kind + "_" + rarity + "_" + name


static func _state_array(state: Object, key: String) -> Array:
	if state == null:
		return []
	var value: Variant = state.get(key)
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []


static func _state_dict(state: Object, key: String) -> Dictionary:
	if state == null:
		return {}
	var value: Variant = state.get(key)
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


static func _state_int(state: Object, key: String, fallback: int = 0) -> int:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback


static func _dict_array(dict: Dictionary, key: String) -> Array:
	var value: Variant = dict.get(key, [])
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []
