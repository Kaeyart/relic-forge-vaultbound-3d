extends RefCounted

# patch_14_inventory_grid_item_state
# Centralizes POE-style inventory state: grid size, item dimensions, item flags,
# appraise/favorite/lock/drop helpers, and safe old-item normalization.

const GRID_COLUMNS: int = 8
const GRID_ROWS: int = 6
const GRID_CELLS: int = GRID_COLUMNS * GRID_ROWS
const INVENTORY_VERSION: int = 2

const SMALL_ONE: Vector2i = Vector2i(1, 1)
const SMALL_TALL: Vector2i = Vector2i(1, 2)
const MEDIUM: Vector2i = Vector2i(2, 2)
const LARGE: Vector2i = Vector2i(2, 3)
const LONG_WEAPON: Vector2i = Vector2i(2, 4)

static func normalize_inventory_state(state: Object) -> bool:
	if state == null:
		return false

	var changed: bool = false
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var occupied: Dictionary = {}

	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = Dictionary(backpack[i])
		if normalize_item(item, i):
			changed = true

		if not _placement_is_valid(item) or _collides(item, occupied):
			var pos: Vector2i = find_free_position(item, occupied)
			item["grid_x"] = pos.x
			item["grid_y"] = pos.y
			changed = true

		_mark_occupied(item, occupied, i)
		backpack[i] = item

	if changed:
		state.set("backpack", backpack)

	return changed


static func normalize_item(item: Dictionary, index: int = 0) -> bool:
	if item.is_empty():
		return false

	var changed: bool = false

	if not item.has("uid") or str(item.get("uid", "")) == "":
		item["uid"] = _make_uid(item, index)
		changed = true

	var size: Vector2i = item_size_for(item)

	if _to_int(item.get("grid_w", 0)) <= 0:
		item["grid_w"] = size.x
		changed = true

	if _to_int(item.get("grid_h", 0)) <= 0:
		item["grid_h"] = size.y
		changed = true

	if not item.has("grid_x"):
		item["grid_x"] = -1
		changed = true

	if not item.has("grid_y"):
		item["grid_y"] = -1
		changed = true

	if not item.has("identified"):
		item["identified"] = true
		changed = true

	if not item.has("favorite"):
		item["favorite"] = false
		changed = true

	if not item.has("locked"):
		item["locked"] = false
		changed = true

	if not item.has("new_item"):
		item["new_item"] = false
		changed = true

	if not item.has("inventory_version") or _to_int(item.get("inventory_version", 0)) < INVENTORY_VERSION:
		item["inventory_version"] = INVENTORY_VERSION
		changed = true

	if not item.has("item_level"):
		item["item_level"] = maxi(1, _to_int(item.get("level", item.get("power", 1)), 1))
		changed = true

	if not item.has("tags") or typeof(item.get("tags", [])) != TYPE_ARRAY:
		item["tags"] = _guess_tags(item)
		changed = true

	return changed


static func item_size_for(item: Dictionary) -> Vector2i:
	var kind: String = _kind(item)
	var slot: String = normalized_slot(item)

	if _is_stackable(item):
		return SMALL_ONE

	if _is_gem(item):
		return SMALL_ONE

	if kind == "map" or slot == "map":
		return SMALL_ONE

	match slot:
		"weapon":
			var weapon_type: String = str(item.get("weapon_type", item.get("base_id", ""))).to_lower()
			if weapon_type.find("two") >= 0 or weapon_type.find("great") >= 0 or weapon_type.find("staff") >= 0 or weapon_type.find("pole") >= 0:
				return LONG_WEAPON
			return LARGE
		"offhand":
			return LARGE
		"chest":
			return LARGE
		"helmet", "head", "gloves", "boots":
			return MEDIUM
		"belt":
			return SMALL_TALL
		"amulet", "ring", "ring_1", "ring_2", "relic":
			return SMALL_ONE
		_:
			return SMALL_ONE


static func find_free_position(item: Dictionary, occupied: Dictionary) -> Vector2i:
	var w: int = clampi(_to_int(item.get("grid_w", 1), 1), 1, GRID_COLUMNS)
	var h: int = clampi(_to_int(item.get("grid_h", 1), 1), 1, GRID_ROWS)

	for y: int in range(GRID_ROWS - h + 1):
		for x: int in range(GRID_COLUMNS - w + 1):
			if _rect_free(x, y, w, h, occupied):
				return Vector2i(x, y)

	return Vector2i(-1, -1)


static func layout_snapshot(state: Object) -> Dictionary:
	normalize_inventory_state(state)

	var out: Dictionary = {}
	var backpack: Array = _as_array(_state_get(state, "backpack", []))

	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = Dictionary(backpack[i])
		var x: int = _to_int(item.get("grid_x", -1), -1)
		var y: int = _to_int(item.get("grid_y", -1), -1)
		var w: int = _to_int(item.get("grid_w", 1), 1)
		var h: int = _to_int(item.get("grid_h", 1), 1)

		if x < 0 or y < 0:
			out["overflow_" + str(i)] = {
				"index": i,
				"origin": false,
				"overflow": true,
				"item": item,
			}
			continue

		for yy: int in range(y, y + h):
			for xx: int in range(x, x + w):
				var key: String = cell_key(xx, yy)
				out[key] = {
					"index": i,
					"origin": xx == x and yy == y,
					"item": item,
				}

	return out


static func cell_key(x: int, y: int) -> String:
	return str(x) + "," + str(y)


static func appraise_selected(state: Object) -> bool:
	var ref: Dictionary = _selected_ref(state)
	if ref.is_empty():
		return false

	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var index: int = _to_int(ref.get("index", -1), -1)
	if index < 0 or index >= backpack.size() or typeof(backpack[index]) != TYPE_DICTIONARY:
		return false

	var item: Dictionary = Dictionary(backpack[index])
	item["identified"] = true
	item["new_item"] = false
	backpack[index] = item
	state.set("backpack", backpack)
	_add_notice(state, "Appraised " + display_name(item) + ".")
	return true


static func toggle_favorite_selected(state: Object) -> bool:
	return _toggle_flag_selected(state, "favorite", "favorite")


static func toggle_locked_selected(state: Object) -> bool:
	return _toggle_flag_selected(state, "locked", "locked")


static func drop_selected(state: Object) -> bool:
	var ref: Dictionary = _selected_ref(state)
	if ref.is_empty():
		return false

	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var index: int = _to_int(ref.get("index", -1), -1)
	if index < 0 or index >= backpack.size() or typeof(backpack[index]) != TYPE_DICTIONARY:
		return false

	var item: Dictionary = Dictionary(backpack[index])
	if bool(item.get("locked", false)) or bool(item.get("favorite", false)):
		_add_notice(state, "Item is locked/favorited. Unlock before dropping.")
		return false

	var name: String = display_name(item)
	backpack.remove_at(index)
	state.set("backpack", backpack)
	state.set("inventory_cursor", clampi(_to_int(_state_get(state, "inventory_cursor", 0), 0), 0, maxi(0, backpack.size() - 1)))
	normalize_inventory_state(state)
	_add_notice(state, "Dropped " + name + ".")
	return true


static func display_name(item: Dictionary) -> String:
	return str(item.get("display_name", item.get("name", item.get("base_id", "Item"))))


static func normalized_slot(item: Dictionary) -> String:
	var slot: String = str(item.get("slot", item.get("equip_slot", item.get("category", "")))).strip_edges().to_lower()
	match slot:
		"helm":
			return "helmet"
		"head":
			return "helmet"
		"ring1":
			return "ring_1"
		"ring2":
			return "ring_2"
		_:
			return slot


static func flag_text(item: Dictionary) -> String:
	var flags: PackedStringArray = PackedStringArray()

	if not bool(item.get("identified", true)):
		flags.append("UNAPPRAISED")

	if bool(item.get("new_item", false)):
		flags.append("NEW")

	if bool(item.get("favorite", false)):
		flags.append("FAVORITE")

	if bool(item.get("locked", false)):
		flags.append("LOCKED")

	if flags.is_empty():
		return ""

	return " · ".join(flags)


static func hidden_affix_text(item: Dictionary) -> String:
	if bool(item.get("identified", true)):
		return ""

	var rarity: String = str(item.get("rarity", "normal")).capitalize()
	var slot: String = normalized_slot(item).replace("_", " ").capitalize()
	var power: int = _to_int(item.get("item_power", item.get("power", item.get("item_level", 1))), 1)
	return "[b]Unappraised " + rarity + " " + slot + "[/b]\nItem Power " + str(power) + "\nAffixes hidden until appraisal.\n[Y] Appraise selected item."


static func _toggle_flag_selected(state: Object, key: String, label: String) -> bool:
	var ref: Dictionary = _selected_ref(state)
	if ref.is_empty():
		return false

	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var index: int = _to_int(ref.get("index", -1), -1)
	if index < 0 or index >= backpack.size() or typeof(backpack[index]) != TYPE_DICTIONARY:
		return false

	var item: Dictionary = Dictionary(backpack[index])
	var new_value: bool = not bool(item.get(key, false))
	item[key] = new_value
	backpack[index] = item
	state.set("backpack", backpack)

	var state_text: String = "enabled" if new_value else "disabled"
	_add_notice(state, label.capitalize() + " " + state_text + ": " + display_name(item))
	return true


static func _selected_ref(state: Object) -> Dictionary:
	if state == null:
		return {}

	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack.is_empty():
		return {}

	var cursor: int = clampi(_to_int(_state_get(state, "inventory_cursor", 0), 0), 0, backpack.size() - 1)
	return {"index": cursor}


static func _placement_is_valid(item: Dictionary) -> bool:
	var x: int = _to_int(item.get("grid_x", -1), -1)
	var y: int = _to_int(item.get("grid_y", -1), -1)
	var w: int = _to_int(item.get("grid_w", 1), 1)
	var h: int = _to_int(item.get("grid_h", 1), 1)

	if x < 0 or y < 0:
		return false

	if x + w > GRID_COLUMNS:
		return false

	if y + h > GRID_ROWS:
		return false

	return true


static func _collides(item: Dictionary, occupied: Dictionary) -> bool:
	var x: int = _to_int(item.get("grid_x", -1), -1)
	var y: int = _to_int(item.get("grid_y", -1), -1)
	var w: int = _to_int(item.get("grid_w", 1), 1)
	var h: int = _to_int(item.get("grid_h", 1), 1)

	if x < 0 or y < 0:
		return false

	for yy: int in range(y, y + h):
		for xx: int in range(x, x + w):
			if occupied.has(cell_key(xx, yy)):
				return true

	return false


static func _rect_free(x: int, y: int, w: int, h: int, occupied: Dictionary) -> bool:
	for yy: int in range(y, y + h):
		for xx: int in range(x, x + w):
			if occupied.has(cell_key(xx, yy)):
				return false

	return true


static func _mark_occupied(item: Dictionary, occupied: Dictionary, index: int) -> void:
	var x: int = _to_int(item.get("grid_x", -1), -1)
	var y: int = _to_int(item.get("grid_y", -1), -1)
	var w: int = _to_int(item.get("grid_w", 1), 1)
	var h: int = _to_int(item.get("grid_h", 1), 1)

	if x < 0 or y < 0:
		return

	for yy: int in range(y, y + h):
		for xx: int in range(x, x + w):
			occupied[cell_key(xx, yy)] = index


static func _is_stackable(item: Dictionary) -> bool:
	if _to_int(item.get("stack", item.get("amount", 1)), 1) > 1:
		return true

	var kind: String = _kind(item)
	return kind in ["currency", "material", "crafting_currency", "shard", "fragment", "essence"]


static func _is_gem(item: Dictionary) -> bool:
	var explicit: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).strip_edges().to_lower()
	if explicit in ["active", "support", "spirit"]:
		return true

	var kind: String = _kind(item)
	return kind in ["active_gem", "support_gem", "spirit_gem", "skill_gem", "active_skill_gem"]


static func _kind(item: Dictionary) -> String:
	return str(item.get("kind", item.get("item_kind", item.get("category", "")))).strip_edges().to_lower()


static func _guess_tags(item: Dictionary) -> Array:
	var tags: Array = []
	var kind: String = _kind(item)
	var slot: String = normalized_slot(item)

	if kind != "":
		tags.append(kind)

	if slot != "":
		tags.append(slot)

	var rarity: String = str(item.get("rarity", "")).strip_edges().to_lower()
	if rarity != "":
		tags.append(rarity)

	if _is_gem(item):
		tags.append("gem")

	if _is_stackable(item):
		tags.append("stackable")

	return tags


static func _make_uid(item: Dictionary, index: int) -> String:
	var base: String = str(item.get("base_id", item.get("id", item.get("name", "item")))).to_lower().replace(" ", "_")
	return "inv_" + base + "_" + str(index) + "_" + str(Time.get_ticks_msec())


static func _add_notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)


static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback

	var value: Variant = state.get(key)
	if value == null:
		return fallback

	return value


static func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)

	return []


static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback

	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		_:
			return fallback
