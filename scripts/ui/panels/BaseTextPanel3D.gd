extends Control

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")
const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")
const CraftingSystemScript := preload("res://scripts/systems/CraftingSystem3D.gd")
const MapLoopSystemScript := preload("res://scripts/systems/MapLoopSystem3D.gd")

@export var panel_mode: String = "inventory"

var state_ref: Object = null
var left_text: RichTextLabel = null
var center_text: RichTextLabel = null
var right_text: RichTextLabel = null

func _ready() -> void:
	_bind_nodes()

func bind_state(state: Object) -> void:
	update_from_state(state)

func update_from_state(state: Object) -> void:
	state_ref = state
	if left_text == null:
		_bind_nodes()
	match panel_mode:
		"inventory": _render_inventory()
		"stash": _render_stash()
		"crafting": _render_crafting()
		"skills": _render_skills()
		"maps": _render_maps()
		"character": _render_character()
		_: _set_columns("", "No panel mode", "")

func _bind_nodes() -> void:
	left_text = get_node_or_null("Root/Left/LeftText") as RichTextLabel
	center_text = get_node_or_null("Root/Center/CenterText") as RichTextLabel
	right_text = get_node_or_null("Root/Right/RightText") as RichTextLabel
	for label_value: Variant in [left_text, center_text, right_text]:
		var label := label_value as RichTextLabel
		if label != null:
			label.bbcode_enabled = true
			label.scroll_active = true
			label.fit_content = false

func _render_inventory() -> void:
	var equipped: Dictionary = Dictionary(_get_value("equipped", {}))
	var left: Array[String] = ["[b]EQUIPPED[/b]", ""]
	var slot_order: Array[String] = ["weapon", "offhand", "helmet", "chest", "gloves", "boots", "amulet", "ring1", "ring2", "belt", "relic"]
	for slot: String in slot_order:
		var item: Dictionary = Dictionary(equipped.get(slot, {}))
		left.append("[color=#d8c18a]" + slot.capitalize() + "[/color]: " + _item_name(item))
	var backpack: Array = Array(_get_value("backpack", []))
	var cursor: int = _i(_get_value("inventory_cursor", 0))
	var center: Array[String] = ["[b]BACKPACK[/b]", "[color=#b8b8b8][ / ] select · U equip[/color]", ""]
	if backpack.is_empty():
		center.append("Backpack empty. Run maps to get gear.")
	else:
		for i: int in range(backpack.size()):
			var item2: Dictionary = Dictionary(backpack[i])
			var marker: String = "[color=#ffd166]>[/color] " if i == cursor else "  "
			center.append(marker + str(i + 1).pad_zeros(2) + "  " + _item_name(item2))
	var selected: Dictionary = {}
	if not backpack.is_empty():
		selected = Dictionary(backpack[wrapi(cursor, 0, backpack.size())])
	var right: String = "[b]SELECTED ITEM[/b]\n\n" + _detail(selected)
	_set_columns("\n".join(left), "\n".join(center), right)

func _render_stash() -> void:
	var backpack: Array = Array(_get_value("backpack", []))
	var stash_items: Array = Array(_get_value("stash", []))
	var tabs: Array = Array(_get_value("stash_tabs", []))
	var left: Array[String] = ["[b]STASH STATUS[/b]", ""]
	left.append("Backpack items: " + str(backpack.size()))
	left.append("Stash items: " + str(stash_items.size()))
	left.append("Tabs detected: " + str(tabs.size()))
	left.append("")
	left.append("[color=#b8b8b8]This patch focuses the layout. Bulk tab rules come after the demo loop stabilizes.[/color]")
	var center: Array[String] = ["[b]BACKPACK SNAPSHOT[/b]", ""]
	for i: int in range(min(18, backpack.size())):
		center.append(str(i + 1).pad_zeros(2) + "  " + _item_name(Dictionary(backpack[i])))
	if backpack.is_empty():
		center.append("No items in backpack.")
	var right: Array[String] = ["[b]STASH FLOW[/b]", "", "Use this station after maps.", "Keep rares/uniques, dump experiments, return to Map Device.", "", "Next later: category tabs, quick transfer, filters."]
	_set_columns("\n".join(left), "\n".join(center), "\n".join(right))

func _render_crafting() -> void:
	var craft_text: String = CraftingSystemScript.panel_text(state_ref)
	var materials: Dictionary = Dictionary(_get_value("materials", {}))
	var left: Array[String] = ["[b]FORGE MATERIALS[/b]", ""]
	if materials.is_empty():
		left.append("No materials yet.")
	else:
		for key: Variant in materials.keys():
			left.append(str(key) + ": " + str(materials[key]))
	var center: String = "[b]CURRENT FORGE[/b]\n\n" + craft_text
	var right: Array[String] = ["[b]FORGE PRIORITY[/b]", "", "1. Upgrade a weapon first.", "2. Improve life/defense if dying.", "3. Polish promising rares.", "", "Do not overcraft trash bases."]
	_set_columns("\n".join(left), center, "\n".join(right))

func _render_skills() -> void:
	SkillGemSystemScript.ensure_defaults(state_ref)
	var skill_text: String = SkillGemSystemScript.panel_text(state_ref)
	var slots: Array = Array(_get_value("active_skill_slots", []))
	var left: Array[String] = ["[b]ACTIVE SLOTS[/b]", ""]
	for i: int in range(slots.size()):
		var slot: Dictionary = Dictionary(slots[i])
		var selected: bool = i == _i(_get_value("selected_skill_slot", 0))
		left.append(("[color=#ffd166]> [/color]" if selected else "  ") + str(i + 1) + "  " + str(slot.get("active", slot.get("active_id", "empty"))))
		left.append("     supports: " + str(Array(slot.get("supports", [])).size()))
	var right: Array[String] = ["[b]GEM EDITING[/b]", "", "1-4 select slot", "A/D cycle active", "S add compatible support", "W remove support", "G toggle spirit", "", "Build rule: supports should change behavior first, damage second."]
	_set_columns("\n".join(left), skill_text, "\n".join(right))

func _render_maps() -> void:
	var map_text: String = MapLoopSystemScript.panel_text(state_ref)
	var maps: Array = Array(_get_value("map_stash", []))
	var cursor: int = _i(_get_value("map_cursor", 0))
	var left: Array[String] = ["[b]AVAILABLE MAPS[/b]", "[color=#b8b8b8][ / ] select · T launch[/color]", ""]
	if maps.is_empty():
		left.append("No map items. A starter map should be granted by state defaults.")
	else:
		for i: int in range(maps.size()):
			var map: Dictionary = Dictionary(maps[i])
			left.append(("[color=#ffd166]> [/color]" if i == cursor else "  ") + str(i + 1).pad_zeros(2) + "  " + str(map.get("display_name", map.get("id", "Map"))))
	var right: Array[String] = ["[b]RUN LOOP[/b]", "", "1. Pick map", "2. Kill packs", "3. Loot", "4. Return hub", "5. Equip / forge / gems", "6. Run again"]
	_set_columns("\n".join(left), map_text, "\n".join(right))

func _render_character() -> void:
	var left: Array[String] = ["[b]CORE[/b]", ""]
	left.append(str(_get_value("class_display_name", "Adventurer")) + " · Level " + str(_get_value("level", 1)))
	left.append("XP: " + str(_get_value("xp", 0)))
	left.append("Life: " + str(_get_value("max_hp", 0)))
	left.append("Mana: " + str(_get_value("max_mana", 0)))
	left.append("Spirit: " + str(_get_value("spirit_reserved", 0)) + " / " + str(_get_value("spirit_max", 0)))
	left.append("Armor: " + str(_get_value("armor", 0)))
	left.append("Move Speed: " + str(_get_value("move_speed", 0)))
	var stats: Dictionary = Dictionary(_get_value("build_stats", {}))
	var center: Array[String] = ["[b]BUILD STATS[/b]", ""]
	if stats.is_empty():
		center.append("No build stats yet.")
	else:
		for key: Variant in stats.keys():
			center.append(str(key).replace("_", " ").capitalize() + ": " + str(stats[key]))
	var rules: Array = Array(_get_value("build_rules", []))
	var right: Array[String] = ["[b]BUILD RULES[/b]", ""]
	if rules.is_empty():
		right.append("No special item rules equipped.")
	else:
		for rule: Variant in rules:
			right.append("• " + str(rule))
	_set_columns("\n".join(left), "\n".join(center), "\n".join(right))

func _set_columns(left: String, center: String, right: String) -> void:
	if left_text != null:
		left_text.text = left
	if center_text != null:
		center_text.text = center
	if right_text != null:
		right_text.text = right

func _item_name(item: Dictionary) -> String:
	if item.is_empty():
		return "—"
	var name: String = str(item.get("display_name", item.get("name", item.get("base_name", "Item"))))
	var rarity: String = str(item.get("rarity", "normal"))
	var color: String = "#d8d8d8"
	match rarity:
		"magic": color = "#7aa2ff"
		"rare": color = "#ffd166"
		"unique": color = "#c77dff"
	return "[color=" + color + "]" + name + "[/color]"

func _detail(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."
	return str(ItemDBScript.item_detail(item))

func _get_value(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback

	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback

	return value

func _i(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT: return value
		TYPE_FLOAT: return int(round(value))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int(): return s.to_int()
			if s.is_valid_float(): return int(round(s.to_float()))
			return fallback
		_: return fallback
