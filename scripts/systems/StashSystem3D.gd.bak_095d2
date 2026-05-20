extends RefCounted

const AFFINITY_NONE: String = "none"
const AFFINITY_CURRENCY: String = "currency"
const AFFINITY_MAPS: String = "maps"
const AFFINITY_GEMS: String = "gems"
const AFFINITY_CRYSTALS: String = "crystals"
const AFFINITY_UNIQUES: String = "uniques"
const AFFINITY_CUSTOM_ITEMS: String = "custom_items"

const AFFINITIES: Array[String] = [
	AFFINITY_NONE,
	AFFINITY_CURRENCY,
	AFFINITY_MAPS,
	AFFINITY_GEMS,
	AFFINITY_CRYSTALS,
	AFFINITY_UNIQUES,
	AFFINITY_CUSTOM_ITEMS,
]

const PLAYER_TAB_AFFINITIES: Array[String] = [
	AFFINITY_NONE,
	AFFINITY_CUSTOM_ITEMS,
]

const SYSTEM_TAB_AFFINITY_BY_ID: Dictionary = {
	"tab_currency": AFFINITY_CURRENCY,
	"tab_maps": AFFINITY_MAPS,
	"tab_gems": AFFINITY_GEMS,
	"tab_crystals": AFFINITY_CRYSTALS,
	"tab_uniques": AFFINITY_UNIQUES,
}

const SYSTEM_TAB_META: Dictionary = {
	"tab_currency": {"name":"Currency", "color":"#d6b55a", "icon":"coin", "affinity":AFFINITY_CURRENCY},
	"tab_maps": {"name":"Maps", "color":"#82aaff", "icon":"map", "affinity":AFFINITY_MAPS},
	"tab_gems": {"name":"Gems", "color":"#b49cff", "icon":"gem", "affinity":AFFINITY_GEMS},
	"tab_crystals": {"name":"Crystals", "color":"#77d9d0", "icon":"crystal", "affinity":AFFINITY_CRYSTALS},
	"tab_uniques": {"name":"Uniques", "color":"#ff963f", "icon":"unique", "affinity":AFFINITY_UNIQUES},
}

const RARITY_RANK: Dictionary = {
	"normal": 0,
	"magic": 1,
	"rare": 2,
	"unique": 3,
}

const SORT_RARITY_RANK: Dictionary = {
	"unique": 0,
	"rare": 1,
	"magic": 2,
	"normal": 3,
}

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return

	var categories: Array = Array(_state_get(state, "stash_categories", []))
	var tabs: Array = Array(_state_get(state, "stash_tabs", []))

	categories = _ensure_category(categories, "cat_general", "General", "#cfcfcf", "box")
	categories = _ensure_category(categories, "cat_affinity", "Affinity", "#9fc7ff", "star")
	categories = _ensure_category(categories, "cat_custom", "Custom", "#cfa9ff", "filter")

	if tabs.is_empty():
		tabs.append(_new_player_tab("tab_general_1", "Tab 1", "cat_general", "#cfcfcf", "box", AFFINITY_NONE))

	tabs = _ensure_system_tab(tabs, "tab_currency")
	tabs = _ensure_system_tab(tabs, "tab_maps")
	tabs = _ensure_system_tab(tabs, "tab_gems")
	tabs = _ensure_system_tab(tabs, "tab_crystals")
	tabs = _ensure_system_tab(tabs, "tab_uniques")

	for i: int in range(categories.size()):
		if typeof(categories[i]) != TYPE_DICTIONARY:
			categories[i] = _new_category("cat_" + str(i), "Category " + str(i + 1), "#cfcfcf", "box")
		else:
			var c: Dictionary = Dictionary(categories[i])
			c["id"] = str(c.get("id", "cat_" + str(i)))
			c["name"] = str(c.get("name", "Category " + str(i + 1)))
			c["color"] = str(c.get("color", "#cfcfcf"))
			c["icon"] = str(c.get("icon", "box"))
			categories[i] = c

	for j: int in range(tabs.size()):
		if typeof(tabs[j]) != TYPE_DICTIONARY:
			tabs[j] = _new_player_tab("tab_" + str(j), "Tab " + str(j + 1), "cat_custom", "#cfcfcf", "box", AFFINITY_NONE)
			continue

		var t: Dictionary = Dictionary(tabs[j])
		var id: String = str(t.get("id", "tab_" + str(j)))
		t["id"] = id
		t["name"] = str(t.get("name", "Tab " + str(j + 1)))
		t["color"] = str(t.get("color", "#cfcfcf"))
		t["icon"] = str(t.get("icon", "box"))

		if typeof(t.get("items", [])) != TYPE_ARRAY:
			t["items"] = []
		if typeof(t.get("custom_rules", {})) != TYPE_DICTIONARY:
			t["custom_rules"] = {}

		if is_system_tab_id(id):
			var meta: Dictionary = Dictionary(SYSTEM_TAB_META[id])
			t["category_id"] = "cat_affinity"
			t["affinity"] = str(meta.get("affinity", AFFINITY_NONE))
			t["system_tab"] = true
			t["locked_affinity"] = true
			if str(t.get("name", "")) == "":
				t["name"] = str(meta.get("name", "Affinity"))
			if str(t.get("color", "")) == "":
				t["color"] = str(meta.get("color", "#cfcfcf"))
			if str(t.get("icon", "")) == "":
				t["icon"] = str(meta.get("icon", "box"))
		else:
			t["system_tab"] = false
			t["locked_affinity"] = false
			var category_id: String = str(t.get("category_id", "cat_custom"))
			if category_id == "" or category_id == "cat_affinity":
				category_id = "cat_custom"
			t["category_id"] = category_id

			var affinity: String = str(t.get("affinity", AFFINITY_NONE))
			if not PLAYER_TAB_AFFINITIES.has(affinity):
				affinity = AFFINITY_CUSTOM_ITEMS
			t["affinity"] = affinity

		tabs[j] = t

	state.set("stash_categories", categories)
	state.set("stash_tabs", tabs)
	rf_090f_repair_state(state)

	var selected_category: String = str(_state_get(state, "selected_stash_category_id", ""))
	if selected_category == "" or selected_category_not_found(categories, selected_category):
		state.set("selected_stash_category_id", "cat_general")

	var selected_tab: String = str(_state_get(state, "selected_stash_tab_id", ""))
	if selected_tab == "" or find_tab_without_ensure(tabs, selected_tab).is_empty():
		state.set("selected_stash_tab_id", "tab_general_1")

	if _state_get(state, "stash_selected_item_index", null) == null:
		state.set("stash_selected_item_index", -1)
	if _state_get(state, "stash_search_query", null) == null:
		state.set("stash_search_query", "")
	if _state_get(state, "stash_search_all", null) == null:
		state.set("stash_search_all", false)
	if _state_get(state, "map_completion", null) == null:
		state.set("map_completion", {})

static func selected_category_not_found(categories: Array, id: String) -> bool:
	for value: Variant in categories:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("id", "")) == id:
			return false
	return true

static func find_tab_without_ensure(tabs: Array, id: String) -> Dictionary:
	for value: Variant in tabs:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("id", "")) == id:
			return Dictionary(value)
	return {}

static func _ensure_category(categories: Array, id: String, name: String, color: String, icon: String) -> Array:
	for i: int in range(categories.size()):
		if typeof(categories[i]) == TYPE_DICTIONARY and str(Dictionary(categories[i]).get("id", "")) == id:
			return categories
	categories.append(_new_category(id, name, color, icon))
	return categories

static func _ensure_system_tab(tabs: Array, id: String) -> Array:
	for i: int in range(tabs.size()):
		if typeof(tabs[i]) == TYPE_DICTIONARY and str(Dictionary(tabs[i]).get("id", "")) == id:
			return tabs
	var meta: Dictionary = Dictionary(SYSTEM_TAB_META[id])
	tabs.append({
		"id": id,
		"name": str(meta.get("name", "Affinity")),
		"category_id": "cat_affinity",
		"color": str(meta.get("color", "#cfcfcf")),
		"icon": str(meta.get("icon", "box")),
		"affinity": str(meta.get("affinity", AFFINITY_NONE)),
		"custom_rules": {},
		"items": [],
		"system_tab": true,
		"locked_affinity": true,
	})
	return tabs

static func _new_category(id: String, name: String, color: String, icon: String) -> Dictionary:
	return {"id": id, "name": name, "color": color, "icon": icon}

static func _new_player_tab(id: String, name: String, category_id: String, color: String, icon: String, affinity: String) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"category_id": category_id,
		"color": color,
		"icon": icon,
		"affinity": affinity if PLAYER_TAB_AFFINITIES.has(affinity) else AFFINITY_NONE,
		"custom_rules": {},
		"items": [],
		"system_tab": false,
		"locked_affinity": false,
	}

static func is_system_tab_id(id: String) -> bool:
	return SYSTEM_TAB_AFFINITY_BY_ID.has(id)

static func tab_buy_cost(state: Object) -> int:
	ensure_defaults(state)
	var bought_count: int = 0
	for value: Variant in Array(_state_get(state, "stash_tabs", [])):
		if typeof(value) == TYPE_DICTIONARY and not bool(Dictionary(value).get("system_tab", false)) and str(Dictionary(value).get("id", "")) != "tab_general_1":
			bought_count += 1
	return 100 + bought_count * 50

static func buy_tab(state: Object) -> String:
	if state == null:
		return "No state"
	ensure_defaults(state)
	rf_090f_repair_state(state)
	var cost: int = tab_buy_cost(state)
	var gold: int = _safe_int(_state_get(state, "gold", 0), 0)
	if gold < cost:
		return "Not enough gold. Need " + str(cost)
	var tabs: Array = Array(_state_get(state, "stash_tabs", []))
	var category_id: String = str(_state_get(state, "selected_stash_category_id", "cat_custom"))
	if category_id == "" or category_id == "cat_affinity":
		category_id = "cat_custom"
	var id: String = "tab_player_" + str(Time.get_ticks_msec()) + "_" + str(tabs.size())
	var player_count: int = 0
	for value: Variant in tabs:
		if typeof(value) == TYPE_DICTIONARY and not bool(Dictionary(value).get("system_tab", false)):
			player_count += 1
	tabs.append(_rf_090f_new_player_tab(id, "Item Tab " + str(player_count + 1), category_id))
	state.set("gold", gold - cost)
	state.set("stash_tabs", tabs)
	state.set("selected_stash_category_id", category_id)
	state.set("selected_stash_tab_id", id)
	state.set("stash_selected_item_index", -1)
	state.set("stash_search_query", "")
	return "Bought item stash tab for " + str(cost) + " gold"

static func _buy_target_category_id(state: Object) -> String:
	var selected: String = str(_state_get(state, "selected_stash_category_id", "cat_custom"))
	if selected == "" or selected == "cat_affinity":
		return "cat_custom"
	return selected

static func _player_tab_count(tabs: Array) -> int:
	var count: int = 0
	for value: Variant in tabs:
		if typeof(value) == TYPE_DICTIONARY and not bool(Dictionary(value).get("system_tab", false)):
			count += 1
	return count

static func create_category(state: Object) -> String:
	ensure_defaults(state)
	var categories: Array = Array(_state_get(state, "stash_categories", []))
	var id: String = "cat_player_" + str(Time.get_ticks_msec()) + "_" + str(categories.size())
	categories.append(_new_category(id, "Category " + str(categories.size() + 1), "#cfcfcf", "folder"))
	state.set("stash_categories", categories)
	state.set("selected_stash_category_id", id)
	return "Created stash category"

static func select_category(state: Object, category_id: String) -> void:
	ensure_defaults(state)
	state.set("selected_stash_category_id", category_id)
	state.set("stash_selected_item_index", -1)
	var tabs: Array = tabs_in_category(state, category_id)
	if not tabs.is_empty():
		state.set("selected_stash_tab_id", str(Dictionary(tabs[0]).get("id", "")))

static func select_tab(state: Object, tab_id: String) -> void:
	ensure_defaults(state)
	var tab: Dictionary = find_tab(state, tab_id)
	if tab.is_empty():
		return
	state.set("selected_stash_tab_id", tab_id)
	state.set("selected_stash_category_id", str(tab.get("category_id", "cat_general")))
	state.set("stash_selected_item_index", -1)

static func customize_selected_tab(state: Object, name: String, color: String, icon: String, affinity: String) -> String:
	return customize_tab(state, str(_state_get(state, "selected_stash_tab_id", "")), name, color, icon, affinity, {})

static func customize_tab(state: Object, tab_id: String, name: String, color: String, icon: String, affinity: String, rules: Dictionary = {}) -> String:
	ensure_defaults(state)
	var tabs: Array = Array(_state_get(state, "stash_tabs", []))
	for i: int in range(tabs.size()):
		if typeof(tabs[i]) != TYPE_DICTIONARY:
			continue
		var tab: Dictionary = Dictionary(tabs[i])
		if str(tab.get("id", "")) != tab_id:
			continue

		if name.strip_edges() != "":
			tab["name"] = name.strip_edges()
		if color.strip_edges() != "":
			tab["color"] = color.strip_edges()
		if icon.strip_edges() != "":
			tab["icon"] = icon.strip_edges()

		if bool(tab.get("system_tab", false)) or is_system_tab_id(str(tab.get("id", ""))):
			tab["affinity"] = str(SYSTEM_TAB_AFFINITY_BY_ID.get(str(tab.get("id", "")), tab.get("affinity", AFFINITY_NONE)))
			tab["system_tab"] = true
			tab["locked_affinity"] = true
			tabs[i] = tab
			state.set("stash_tabs", tabs)
			return "Updated system affinity tab. Affinity is fixed."
		else:
			if affinity == AFFINITY_CUSTOM_ITEMS:
				tab["affinity"] = AFFINITY_CUSTOM_ITEMS
				tab["custom_rules"] = _sanitize_custom_rules(rules)
			elif affinity == AFFINITY_NONE:
				tab["affinity"] = AFFINITY_NONE
				if not rules.is_empty():
					tab["custom_rules"] = _sanitize_custom_rules(rules)
			else:
				tab["affinity"] = AFFINITY_CUSTOM_ITEMS
				tab["custom_rules"] = _sanitize_custom_rules(rules)
				tabs[i] = tab
				state.set("stash_tabs", tabs)
				return "Updated tab as custom item tab. Special affinity tabs are built-in."

		tabs[i] = tab
		state.set("stash_tabs", tabs)
		return "Updated stash tab"
	return "No stash tab selected"

static func _sanitize_custom_rules(rules: Dictionary) -> Dictionary:
	var clean: Dictionary = {}
	clean["rarity"] = str(rules.get("rarity", "")).strip_edges().to_lower()
	clean["slot"] = str(rules.get("slot", "")).strip_edges().to_lower()
	clean["kind"] = str(rules.get("kind", "")).strip_edges().to_lower()
	clean["min_tier"] = _safe_int(rules.get("min_tier", 0), 0)
	clean["max_tier"] = _safe_int(rules.get("max_tier", 0), 0)
	return clean

static func deposit_selected_inventory_item(state: Object) -> String:
	ensure_defaults(state)
	var backpack: Array = Array(_state_get(state, "backpack", []))
	if backpack.is_empty():
		return "Inventory is empty"

	var cursor: int = clampi(_safe_int(_state_get(state, "inventory_cursor", 0), 0), 0, backpack.size() - 1)
	if cursor < 0 or cursor >= backpack.size() or typeof(backpack[cursor]) != TYPE_DICTIONARY:
		return "No item selected"

	var item: Dictionary = Dictionary(backpack[cursor])
	var tab_id: String = find_target_tab_for_item(state, item)
	if tab_id == "":
		return "No stash tab available"

	var tabs: Array = Array(_state_get(state, "stash_tabs", []))
	for i: int in range(tabs.size()):
		if typeof(tabs[i]) != TYPE_DICTIONARY:
			continue
		var tab: Dictionary = Dictionary(tabs[i])
		if str(tab.get("id", "")) != tab_id:
			continue

		var items: Array = Array(tab.get("items", []))
		item.erase("grid_x")
		item.erase("grid_y")
		if not _try_stack_item_into(items, item):
			items.append(item)

		tab["items"] = _sorted_items_for_affinity(items, str(tab.get("affinity", AFFINITY_NONE)))
		tabs[i] = tab
		backpack.remove_at(cursor)

		state.set("stash_tabs", tabs)
		state.set("backpack", backpack)
		state.set("inventory_cursor", clampi(cursor, 0, max(0, backpack.size() - 1)))
		state.set("selected_stash_category_id", str(tab.get("category_id", "cat_general")))
		state.set("selected_stash_tab_id", tab_id)
		state.set("stash_selected_item_index", max(0, Array(tab["items"]).size() - 1))
		return "Deposited to " + str(tab.get("name", "stash"))

	return "No stash tab available"

static func withdraw_selected_stash_item(state: Object) -> String:
	ensure_defaults(state)
	var tab_id: String = str(_state_get(state, "selected_stash_tab_id", ""))
	var idx: int = _safe_int(_state_get(state, "stash_selected_item_index", -1), -1)
	if idx < 0:
		return "No stash item selected"

	var tabs: Array = Array(_state_get(state, "stash_tabs", []))
	var backpack: Array = Array(_state_get(state, "backpack", []))

	for i: int in range(tabs.size()):
		if typeof(tabs[i]) != TYPE_DICTIONARY:
			continue
		var tab: Dictionary = Dictionary(tabs[i])
		if str(tab.get("id", "")) != tab_id:
			continue
		var items: Array = Array(tab.get("items", []))
		if idx < 0 or idx >= items.size() or typeof(items[idx]) != TYPE_DICTIONARY:
			return "No stash item selected"
		var item: Dictionary = Dictionary(items[idx])
		items.remove_at(idx)
		tab["items"] = items
		tabs[i] = tab
		backpack.append(item)

		state.set("stash_tabs", tabs)
		state.set("backpack", backpack)
		state.set("inventory_cursor", backpack.size() - 1)
		state.set("stash_selected_item_index", clampi(idx, -1, items.size() - 1))
		return "Withdrew item"

	return "No stash tab selected"

static func tabs_in_category(state: Object, category_id: String) -> Array:
	ensure_defaults(state)
	var out: Array = []
	for v: Variant in Array(_state_get(state, "stash_tabs", [])):
		if typeof(v) == TYPE_DICTIONARY and str(Dictionary(v).get("category_id", "")) == category_id:
			out.append(Dictionary(v))
	return out

static func find_tab(state: Object, tab_id: String) -> Dictionary:
	ensure_defaults(state)
	for v: Variant in Array(_state_get(state, "stash_tabs", [])):
		if typeof(v) == TYPE_DICTIONARY and str(Dictionary(v).get("id", "")) == tab_id:
			return Dictionary(v)
	return {}

static func find_target_tab_for_item(state: Object, item: Dictionary) -> String:
	ensure_defaults(state)
	var item_affinity: String = affinity_for_item(item)
	var tabs: Array = Array(_state_get(state, "stash_tabs", []))

	if item_affinity in [AFFINITY_CURRENCY, AFFINITY_MAPS, AFFINITY_GEMS, AFFINITY_CRYSTALS]:
		for v: Variant in tabs:
			if typeof(v) == TYPE_DICTIONARY and str(Dictionary(v).get("affinity", AFFINITY_NONE)) == item_affinity and bool(Dictionary(v).get("system_tab", false)):
				return str(Dictionary(v).get("id", ""))

	for cv: Variant in tabs:
		if typeof(cv) != TYPE_DICTIONARY:
			continue
		var custom_tab: Dictionary = Dictionary(cv)
		if str(custom_tab.get("affinity", AFFINITY_NONE)) == AFFINITY_CUSTOM_ITEMS and custom_rules_match(item, Dictionary(custom_tab.get("custom_rules", {}))):
			return str(custom_tab.get("id", ""))

	if item_affinity == AFFINITY_UNIQUES:
		for uv: Variant in tabs:
			if typeof(uv) == TYPE_DICTIONARY and str(Dictionary(uv).get("affinity", AFFINITY_NONE)) == AFFINITY_UNIQUES and bool(Dictionary(uv).get("system_tab", false)):
				return str(Dictionary(uv).get("id", ""))

	var selected: Dictionary = find_tab(state, str(_state_get(state, "selected_stash_tab_id", "")))
	if not selected.is_empty() and str(selected.get("affinity", AFFINITY_NONE)) == AFFINITY_NONE and not bool(selected.get("system_tab", false)):
		return str(selected.get("id", ""))

	for fallback: Variant in tabs:
		if typeof(fallback) == TYPE_DICTIONARY and str(Dictionary(fallback).get("affinity", AFFINITY_NONE)) == AFFINITY_NONE and not bool(Dictionary(fallback).get("system_tab", false)):
			return str(Dictionary(fallback).get("id", ""))
	return ""

static func custom_rules_match(item: Dictionary, rules: Dictionary) -> bool:
	var rarity_rule: String = str(rules.get("rarity", "")).strip_edges().to_lower()
	var slot_rule: String = str(rules.get("slot", "")).strip_edges().to_lower()
	var kind_rule: String = str(rules.get("kind", "")).strip_edges().to_lower()
	var min_tier: int = _safe_int(rules.get("min_tier", 0), 0)
	var max_tier: int = _safe_int(rules.get("max_tier", 0), 0)

	var item_rarity: String = str(item.get("rarity", "normal")).strip_edges().to_lower()
	var item_slot: String = normalized_slot(item)
	var item_kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).strip_edges().to_lower()
	var tier: int = map_tier(item)

	if rarity_rule != "" and rarity_rule != "any" and item_rarity != rarity_rule:
		return false
	if slot_rule != "" and slot_rule != "any" and item_slot != slot_rule:
		return false
	if kind_rule != "" and kind_rule != "any" and item_kind != kind_rule:
		return false
	if min_tier > 0 and tier < min_tier:
		return false
	if max_tier > 0 and tier > max_tier:
		return false

	return rarity_rule != "" or slot_rule != "" or kind_rule != "" or min_tier > 0 or max_tier > 0

static func affinity_for_item(item: Dictionary) -> String:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).strip_edges().to_lower()
	var slot: String = str(item.get("slot", "")).strip_edges().to_lower()
	var rarity: String = str(item.get("rarity", "normal")).strip_edges().to_lower()
	var tags: Array[String] = _lower_tags(item)

	if kind in ["currency", "material", "crafting_currency", "shard"] or tags.has("currency") or tags.has("material"):
		return AFFINITY_CURRENCY
	if kind in ["map", "map_item"] or slot == "map" or tags.has("map"):
		return AFFINITY_MAPS
	if _is_gem_item(item):
		return AFFINITY_GEMS
	if kind in ["crystal", "crystallized", "crystallized_mob_drop"] or tags.has("crystal") or tags.has("crystallized"):
		return AFFINITY_CRYSTALS
	if rarity == "unique":
		return AFFINITY_UNIQUES
	return AFFINITY_NONE

static func visible_items_for_current_view(state: Object) -> Array:
	ensure_defaults(state)
	var q: String = str(_state_get(state, "stash_search_query", "")).strip_edges()
	var all: bool = bool(_state_get(state, "stash_search_all", false))
	if all and q != "":
		return search_all_items(state, q)

	var tab: Dictionary = find_tab(state, str(_state_get(state, "selected_stash_tab_id", "")))
	if tab.is_empty():
		return []

	var items: Array = _sorted_items_for_affinity(Array(tab.get("items", [])), str(tab.get("affinity", AFFINITY_NONE)))
	return _filter_items(items, str(tab.get("id", "")), q, str(tab.get("name", "")))

static func search_all_items(state: Object, query: String) -> Array:
	var out: Array = []
	for tv: Variant in Array(_state_get(state, "stash_tabs", [])):
		if typeof(tv) != TYPE_DICTIONARY:
			continue
		var tab: Dictionary = Dictionary(tv)
		var items: Array = _sorted_items_for_affinity(Array(tab.get("items", [])), str(tab.get("affinity", AFFINITY_NONE)))
		out.append_array(_filter_items(items, str(tab.get("id", "")), query, str(tab.get("name", "Tab"))))
	return out

static func _filter_items(items: Array, tab_id: String, query: String, tab_name: String = "") -> Array:
	var out: Array = []
	for i: int in range(items.size()):
		if typeof(items[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(items[i])
		if query == "" or item_matches_query(item, query):
			item["_stash_tab_id"] = tab_id
			item["_stash_item_index"] = i
			item["_stash_tab_name"] = tab_name
			out.append(item)
	return out

static func item_matches_query(item: Dictionary, query: String) -> bool:
	var q: String = query.strip_edges().to_lower()
	if q == "":
		return true
	var parts: PackedStringArray = []
	parts.append(str(item.get("display_name", item.get("name", ""))).to_lower())
	parts.append(str(item.get("rarity", "")).to_lower())
	parts.append(normalized_slot(item))
	parts.append(str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower())
	parts.append(str(item.get("tier", item.get("map_tier", ""))).to_lower())
	parts.append(str(item.get("gem_type", item.get("skill_gem_type", ""))).to_lower())
	parts.append(str(item.get("base_color", item.get("gem_color", ""))).to_lower())
	parts.append("carved" if bool(item.get("carved", false)) else "uncarved")
	for k: Variant in Dictionary(item.get("total_stats", {})).keys():
		parts.append(str(k).to_lower())
	for tag: String in _lower_tags(item):
		parts.append(tag)
	return " ".join(parts).find(q) >= 0

static func item_display_line(state: Object, item: Dictionary) -> String:
	var name: String = _short(str(item.get("display_name", item.get("name", "Item"))), 18)
	var rarity: String = str(item.get("rarity", "normal")).to_upper()
	var aff: String = affinity_for_item(item)

	match aff:
		AFFINITY_MAPS:
			return map_item_display_line(state, item)
		AFFINITY_GEMS:
			var gem_type: String = str(item.get("gem_type", item.get("skill_gem_type", item.get("kind", "gem")))).capitalize()
			var color: String = str(item.get("base_color", item.get("gem_color", "base"))).capitalize()
			var carved: String = "Carved" if bool(item.get("carved", false)) else "Uncarved"
			var level: int = _safe_int(item.get("level", item.get("gem_level", 1)), 1)
			var quality: int = _safe_int(item.get("quality", item.get("gem_quality", 0)), 0)
			return gem_type + " · " + color + "\n" + name + "\nLv " + str(level) + " Q+" + str(quality) + "% · " + carved
		AFFINITY_CURRENCY:
			return "Currency\n" + name + "\nx" + str(_stack_amount(item))
		AFFINITY_CRYSTALS:
			return "Crystal\n" + name + "\nx" + str(_stack_amount(item))
		AFFINITY_UNIQUES:
			var q: int = _safe_int(item.get("quality", item.get("unique_quality", 0)), 0)
			var power: int = _safe_int(item.get("power_tier", item.get("unique_tier", 1)), 1)
			return "UNIQUE T" + str(power) + "\n" + name + "\nQ+" + str(q) + "%"
		_:
			return rarity + "\n" + name + "\n" + normalized_slot(item).capitalize()

static func map_item_display_line(state: Object, item: Dictionary) -> String:
	var name: String = _short(str(item.get("display_name", item.get("name", "Map"))), 18)
	var rarity: String = str(item.get("rarity", "normal")).to_upper()
	var tier: int = map_tier(item)
	var map_id: String = map_id_for_item(item)
	var completion: Dictionary = Dictionary(_state_get(state, "map_completion", {}))
	var entry: Dictionary = Dictionary(completion.get(map_id, {}))
	var done: String = "✓" if bool(entry.get("completed", false)) else "—"
	var bonus: String = "★" if bool(entry.get("bonus_completed", false)) else "☆"
	return "T" + str(tier) + " " + rarity + "\n" + name + "\n" + done + " " + bonus + " · " + map_bonus_requirement_text(item)

static func map_id_for_item(item: Dictionary) -> String:
	return str(item.get("map_id", item.get("id", str(item.get("name", "map")).to_lower().replace(" ", "_"))))

static func map_tier(item: Dictionary) -> int:
	return clampi(_safe_int(item.get("tier", item.get("map_tier", 1)), 1), 1, 15)

static func map_bonus_requirement_text(item: Dictionary) -> String:
	var tier: int = map_tier(item)
	if tier <= 5:
		return "Bonus: clear"
	if tier <= 9:
		return "Bonus: magic+"
	return "Bonus: rare"

static func map_bonus_requirements_met(item: Dictionary) -> bool:
	var tier: int = map_tier(item)
	var rarity: String = str(item.get("rarity", "normal")).strip_edges().to_lower()
	var rank: int = int(RARITY_RANK.get(rarity, 0))
	if tier <= 5:
		return rank >= 0
	if tier <= 9:
		return rank >= int(RARITY_RANK.get("magic", 1))
	return rank >= int(RARITY_RANK.get("rare", 2))

static func complete_map_item(state: Object, item: Dictionary, completed_extra_goal: bool) -> void:
	ensure_defaults(state)
	var map_id: String = map_id_for_item(item)
	var completion: Dictionary = Dictionary(_state_get(state, "map_completion", {}))
	var entry: Dictionary = Dictionary(completion.get(map_id, {}))
	entry["completed"] = true
	entry["highest_completed_rarity"] = _higher_rarity(str(entry.get("highest_completed_rarity", "normal")), str(item.get("rarity", "normal")))
	entry["highest_tier_completed"] = max(_safe_int(entry.get("highest_tier_completed", 0), 0), map_tier(item))
	if completed_extra_goal and map_bonus_requirements_met(item):
		entry["bonus_completed"] = true
	completion[map_id] = entry
	state.set("map_completion", completion)

static func _higher_rarity(a: String, b: String) -> String:
	return a if int(RARITY_RANK.get(a, 0)) >= int(RARITY_RANK.get(b, 0)) else b

static func tab_summary_line(tab: Dictionary) -> String:
	var affinity: String = str(tab.get("affinity", AFFINITY_NONE))
	var items: Array = Array(tab.get("items", []))
	if bool(tab.get("system_tab", false)):
		return "Built-in affinity tab · " + affinity + " · " + str(items.size()) + " items"
	match affinity:
		AFFINITY_CUSTOM_ITEMS:
			return "Custom item rules: " + custom_rules_text(Dictionary(tab.get("custom_rules", {})))
		_:
			return "Player item tab · " + str(items.size()) + " items"

static func custom_rules_text(rules: Dictionary) -> String:
	if rules.is_empty():
		return "not configured"
	var parts: Array[String] = []
	var rarity: String = str(rules.get("rarity", "")).strip_edges()
	var slot: String = str(rules.get("slot", "")).strip_edges()
	var kind: String = str(rules.get("kind", "")).strip_edges()
	var min_tier: int = _safe_int(rules.get("min_tier", 0), 0)
	var max_tier: int = _safe_int(rules.get("max_tier", 0), 0)
	if rarity != "" and rarity != "any":
		parts.append("rarity=" + rarity)
	if slot != "" and slot != "any":
		parts.append("slot=" + slot)
	if kind != "" and kind != "any":
		parts.append("kind=" + kind)
	if min_tier > 0:
		parts.append("minT=" + str(min_tier))
	if max_tier > 0:
		parts.append("maxT=" + str(max_tier))
	return ", ".join(parts) if not parts.is_empty() else "any"

static func _try_stack_item_into(items: Array, item: Dictionary) -> bool:
	var aff: String = affinity_for_item(item)
	if aff != AFFINITY_CURRENCY and aff != AFFINITY_CRYSTALS:
		return false
	var key: String = stack_key(item)
	for i: int in range(items.size()):
		if typeof(items[i]) != TYPE_DICTIONARY:
			continue
		var existing: Dictionary = Dictionary(items[i])
		if stack_key(existing) == key:
			var total: int = _stack_amount(existing) + _stack_amount(item)
			existing["stack"] = total
			existing["amount"] = total
			items[i] = existing
			return true
	return false

static func stack_key(item: Dictionary) -> String:
	return str(item.get("id", item.get("base_id", item.get("display_name", item.get("name", "item"))))).to_lower()

static func _stack_amount(item: Dictionary) -> int:
	return max(1, _safe_int(item.get("stack", item.get("amount", 1)), 1))

static func _sorted_items_for_affinity(items: Array, affinity: String) -> Array:
	var out: Array = []
	for v: Variant in items:
		if typeof(v) == TYPE_DICTIONARY:
			out.append(Dictionary(v))
	var sorted: Array = []
	while not out.is_empty():
		var best_index: int = 0
		for i: int in range(1, out.size()):
			if _item_less(Dictionary(out[i]), Dictionary(out[best_index]), affinity):
				best_index = i
		sorted.append(out[best_index])
		out.remove_at(best_index)
	return sorted

static func _item_less(a: Dictionary, b: Dictionary, affinity: String) -> bool:
	var ka: Array = _sort_key(a, affinity)
	var kb: Array = _sort_key(b, affinity)
	for i: int in range(min(ka.size(), kb.size())):
		if ka[i] == kb[i]:
			continue
		return ka[i] < kb[i]
	return false

static func _sort_key(item: Dictionary, affinity: String) -> Array:
	var name: String = str(item.get("display_name", item.get("name", ""))).to_lower()
	match affinity:
		AFFINITY_MAPS:
			return [map_tier(item), int(SORT_RARITY_RANK.get(str(item.get("rarity", "normal")).to_lower(), 9)), name]
		AFFINITY_GEMS:
			return [str(item.get("gem_type", item.get("skill_gem_type", item.get("kind", "")))).to_lower(), str(item.get("base_color", item.get("gem_color", ""))).to_lower(), 0 if bool(item.get("carved", false)) else 1, name]
		AFFINITY_UNIQUES:
			return [-_safe_int(item.get("power_tier", item.get("unique_tier", 1)), 1), -_safe_int(item.get("quality", item.get("unique_quality", 0)), 0), name]
		_:
			return [int(SORT_RARITY_RANK.get(str(item.get("rarity", "normal")).to_lower(), 9)), normalized_slot(item), name]

static func normalized_slot(item: Dictionary) -> String:
	var slot: String = str(item.get("slot", "")).strip_edges().to_lower()
	match slot:
		"helm":
			return "head"
		"ring":
			return "ring1"
		_:
			return slot

static func _is_gem_item(item: Dictionary) -> bool:
	var explicit: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).to_lower()
	if explicit in ["active", "support", "spirit"]:
		return true
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	if kind in ["active_gem", "active_skill_gem", "support_gem", "spirit_gem", "skill_gem"]:
		return true
	var slot: String = str(item.get("slot", "")).to_lower()
	if slot in ["active_gem", "support_gem", "spirit_gem"]:
		return true
	for tag: String in _lower_tags(item):
		if tag in ["gem", "active_gem", "support_gem", "spirit_gem"]:
			return true
	return false

static func _lower_tags(item: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for tag: Variant in Array(item.get("tags", [])):
		out.append(str(tag).strip_edges().to_lower())
	return out

static func _short(value: String, limit: int) -> String:
	return value if value.length() <= limit else value.substr(0, limit - 1) + "…"

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

static func _safe_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			return s.to_int() if s.is_valid_int() else fallback
		_:
			return fallback

# RF-090F mandatory stash tab repair layer.
const RF_090F_SYSTEM_TAB_IDS: Array[String] = ["tab_currency", "tab_maps", "tab_gems", "tab_crystals", "tab_uniques"]
const RF_090F_SYSTEM_TABS: Dictionary = {
	"tab_currency": {"name":"Currency", "color":"#d6b55a", "icon":"coin", "affinity":"currency"},
	"tab_maps": {"name":"Maps", "color":"#82aaff", "icon":"map", "affinity":"maps"},
	"tab_gems": {"name":"Gems", "color":"#b49cff", "icon":"gem", "affinity":"gems"},
	"tab_crystals": {"name":"Crystals", "color":"#77d9d0", "icon":"crystal", "affinity":"crystals"},
	"tab_uniques": {"name":"Uniques", "color":"#ff963f", "icon":"unique", "affinity":"uniques"},
}

static func rf_090f_repair_state(state: Object) -> void:
	if state == null:
		return
	var categories: Array = Array(_state_get(state, "stash_categories", []))
	categories = _rf_090f_ensure_category(categories, "cat_general", "General", "#cfcfcf", "box")
	categories = _rf_090f_ensure_category(categories, "cat_affinity", "Affinity", "#9fc7ff", "star")
	categories = _rf_090f_ensure_category(categories, "cat_custom", "Custom", "#cfa9ff", "filter")

	var tabs: Array = Array(_state_get(state, "stash_tabs", []))
	if tabs.is_empty():
		tabs.append(_rf_090f_new_player_tab("tab_general_1", "Tab 1", "cat_general"))
	for id: String in RF_090F_SYSTEM_TAB_IDS:
		tabs = _rf_090f_ensure_system_tab(tabs, id)
	tabs = _rf_090f_normalize_tabs(tabs)

	state.set("stash_categories", categories)
	state.set("stash_tabs", tabs)

	var selected_category: String = str(_state_get(state, "selected_stash_category_id", ""))
	if selected_category == "" or not _rf_090f_category_exists(categories, selected_category):
		state.set("selected_stash_category_id", "cat_general")
	var selected_tab: String = str(_state_get(state, "selected_stash_tab_id", ""))
	if selected_tab == "" or _rf_090f_find_tab(tabs, selected_tab).is_empty():
		state.set("selected_stash_tab_id", "tab_general_1")
	if _state_get(state, "stash_selected_item_index", null) == null:
		state.set("stash_selected_item_index", -1)
	if _state_get(state, "stash_search_query", null) == null:
		state.set("stash_search_query", "")
	if _state_get(state, "stash_search_all", null) == null:
		state.set("stash_search_all", false)
	if _state_get(state, "map_completion", null) == null:
		state.set("map_completion", {})

static func _rf_090f_ensure_category(categories: Array, id: String, name: String, color: String, icon: String) -> Array:
	for value: Variant in categories:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("id", "")) == id:
			return categories
	categories.append({"id":id, "name":name, "color":color, "icon":icon})
	return categories

static func _rf_090f_ensure_system_tab(tabs: Array, id: String) -> Array:
	for value: Variant in tabs:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("id", "")) == id:
			return tabs
	var meta: Dictionary = Dictionary(RF_090F_SYSTEM_TABS[id])
	tabs.append({"id":id, "name":meta["name"], "category_id":"cat_affinity", "color":meta["color"], "icon":meta["icon"], "affinity":meta["affinity"], "custom_rules":{}, "items":[], "system_tab":true, "locked_affinity":true})
	return tabs

static func _rf_090f_normalize_tabs(tabs: Array) -> Array:
	for i: int in range(tabs.size()):
		if typeof(tabs[i]) != TYPE_DICTIONARY:
			tabs[i] = _rf_090f_new_player_tab("tab_player_repaired_" + str(i), "Item Tab " + str(i + 1), "cat_custom")
			continue
		var tab: Dictionary = Dictionary(tabs[i])
		var id: String = str(tab.get("id", "tab_player_repaired_" + str(i)))
		tab["id"] = id
		if typeof(tab.get("items", [])) != TYPE_ARRAY:
			tab["items"] = []
		if typeof(tab.get("custom_rules", {})) != TYPE_DICTIONARY:
			tab["custom_rules"] = {}
		if RF_090F_SYSTEM_TABS.has(id):
			var meta: Dictionary = Dictionary(RF_090F_SYSTEM_TABS[id])
			tab["name"] = str(meta["name"])
			tab["category_id"] = "cat_affinity"
			tab["color"] = str(meta["color"])
			tab["icon"] = str(meta["icon"])
			tab["affinity"] = str(meta["affinity"])
			tab["system_tab"] = true
			tab["locked_affinity"] = true
			tab["custom_rules"] = {}
		else:
			tab["name"] = str(tab.get("name", "Item Tab " + str(i + 1)))
			tab["color"] = str(tab.get("color", "#cfcfcf"))
			tab["icon"] = str(tab.get("icon", "box"))
			tab["system_tab"] = false
			tab["locked_affinity"] = false
			var category_id: String = str(tab.get("category_id", "cat_custom"))
			if category_id == "" or category_id == "cat_affinity":
				category_id = "cat_custom"
			tab["category_id"] = category_id
			var affinity: String = str(tab.get("affinity", "none"))
			if affinity != "none" and affinity != "custom_items":
				affinity = "custom_items"
			tab["affinity"] = affinity
		tabs[i] = tab
	return tabs

static func _rf_090f_new_player_tab(id: String, name: String, category_id: String) -> Dictionary:
	return {"id":id, "name":name, "category_id":category_id, "color":"#cfcfcf", "icon":"box", "affinity":"none", "custom_rules":{}, "items":[], "system_tab":false, "locked_affinity":false}

static func _rf_090f_category_exists(categories: Array, id: String) -> bool:
	for value: Variant in categories:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("id", "")) == id:
			return true
	return false

static func _rf_090f_find_tab(tabs: Array, id: String) -> Dictionary:
	for value: Variant in tabs:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("id", "")) == id:
			return Dictionary(value)
	return {}



static func quick_deposit_inventory(state: Object) -> String:
	if state == null:
		return "No state"
	ensure_defaults(state)
	var moved: int = 0
	var safety: int = Array(_state_get(state, "backpack", [])).size()
	for _i: int in range(safety):
		var backpack: Array = Array(_state_get(state, "backpack", []))
		if backpack.is_empty():
			break
		state.set("inventory_cursor", 0)
		var before_count: int = backpack.size()
		var _msg: String = deposit_selected_inventory_item(state)
		var after_count: int = Array(_state_get(state, "backpack", [])).size()
		if after_count < before_count:
			moved += 1
		else:
			break
	return "Quick deposited " + str(moved) + " item(s)"

static func _rf095b_state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value


static func _rf095b_to_int(value: Variant, fallback: int = 0) -> int:
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


static func _rf095b_make_tab(id: String, category_id: String, name: String, affinity: String, color: String) -> Dictionary:
	return {
		"id": id,
		"category_id": category_id,
		"name": name,
		"affinity": affinity,
		"color": color,
		"icon": "box",
		"items": [],
		"custom_rules": {},
	}


static func _rf095b_is_map_item(item: Dictionary) -> bool:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	var slot: String = str(item.get("slot", "")).to_lower()
	return kind == "map" or kind == "map_item" or slot == "map" or item.has("map_tier") or item.has("tier")


static func _rf095b_is_gem_item(item: Dictionary) -> bool:
	var gem_type: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).to_lower()
	if gem_type == "active" or gem_type == "support" or gem_type == "spirit":
		return true
	var kind: String = str(item.get("kind", item.get("item_kind", ""))).to_lower()
	return kind == "active_gem" or kind == "support_gem" or kind == "spirit_gem" or kind == "skill_gem"


static func _rf095b_route_affinity(item: Dictionary) -> String:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	var rarity: String = str(item.get("rarity", "normal")).to_lower()
	if kind == "currency" or kind == "material" or kind == "shard":
		return "currency"
	if _rf095b_is_map_item(item):
		return "maps"
	if _rf095b_is_gem_item(item):
		return "gems"
	if kind == "crystal" or kind == "crystallized":
		return "crystals"
	if rarity == "unique":
		return "uniques"
	return "custom_items"


static func _rf095b_find_target_tab_index(tabs: Array, item: Dictionary) -> int:
	var affinity: String = _rf095b_route_affinity(item)
	for i: int in range(tabs.size()):
		if typeof(tabs[i]) == TYPE_DICTIONARY and str(Dictionary(tabs[i]).get("affinity", "")) == affinity:
			return i
	for j: int in range(tabs.size()):
		if typeof(tabs[j]) == TYPE_DICTIONARY and str(Dictionary(tabs[j]).get("affinity", "")) == "custom_items":
			return j
	return -1


static func _rf095b_item_matches_query(item: Dictionary, query: String) -> bool:
	var q: String = query.strip_edges().to_lower()
	if q == "":
		return true
	var haystack: String = (
		str(item.get("display_name", "")) + " " +
		str(item.get("name", "")) + " " +
		str(item.get("rarity", "")) + " " +
		str(item.get("slot", "")) + " " +
		str(item.get("kind", item.get("item_kind", ""))) + " " +
		str(item.get("gem_type", item.get("skill_gem_type", "")))
	).to_lower()
	return haystack.find(q) >= 0
