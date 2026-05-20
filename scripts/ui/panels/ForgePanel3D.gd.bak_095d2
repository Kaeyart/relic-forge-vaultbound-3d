extends Control

const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")

const OP_REFINE: String = "refine_values"
const OP_ADD_AFFIX: String = "add_affix"
const OP_UPGRADE_RARITY: String = "upgrade_rarity"
const OP_ADD_QUALITY: String = "add_quality"
const OP_RESTORE_POTENTIAL: String = "restore_potential"

const OPERATION_ORDER: Array[String] = [
	OP_REFINE,
	OP_ADD_AFFIX,
	OP_UPGRADE_RARITY,
	OP_ADD_QUALITY,
	OP_RESTORE_POTENTIAL,
]

var state_ref: Object = null
var selected_item_index: int = -1
var selected_operation: String = OP_REFINE
var _last_signature: String = ""

var _root: PanelContainer = null
var _item_list: VBoxContainer = null
var _operation_list: VBoxContainer = null
var _current_card: RichTextLabel = null
var _preview_card: RichTextLabel = null
var _cost_label: RichTextLabel = null
var _notice_label: Label = null
var _currency_label: Label = null


func _ready() -> void:
	_ensure_ui()
	set_process(false)


func bind_state(state: Object) -> void:
	state_ref = state
	_refresh(true)


func update_from_state(state: Object) -> void:
	state_ref = state
	_refresh(false)


func _ensure_ui() -> void:
	if _root != null and is_instance_valid(_root):
		return

	_clear_children(self)

	_root = PanelContainer.new()
	_root.name = "ForgeRoot094E"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var margin: MarginContainer = _margin(16)
	_root.add_child(margin)

	var main: VBoxContainer = VBoxContainer.new()
	main.add_theme_constant_override("separation", 10)
	margin.add_child(main)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	main.add_child(header)

	var title: Label = Label.new()
	title.text = "Forge"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	_currency_label = Label.new()
	_currency_label.text = ""
	_currency_label.custom_minimum_size = Vector2(300, 0)
	header.add_child(_currency_label)

	var close_button: Button = _button("Close", Vector2(86, 34))
	close_button.pressed.connect(_close_panel)
	header.add_child(close_button)

	var hint: RichTextLabel = RichTextLabel.new()
	hint.bbcode_enabled = true
	hint.fit_content = true
	hint.scroll_active = false
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.custom_minimum_size = Vector2(0, 44)
	hint.text = "[b]Forge Workbench[/b] · Choose an item, choose an operation, inspect cost/risk/preview, then apply. Crafting spends forge potential unless the operation says otherwise."
	main.add_child(hint)

	var body: HBoxContainer = HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(body)

	var item_panel: PanelContainer = PanelContainer.new()
	item_panel.custom_minimum_size = Vector2(300, 0)
	item_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(item_panel)

	var item_margin: MarginContainer = _margin(10)
	item_panel.add_child(item_margin)

	var item_box: VBoxContainer = VBoxContainer.new()
	item_box.add_theme_constant_override("separation", 8)
	item_margin.add_child(item_box)

	var item_title: Label = Label.new()
	item_title.text = "Item Input"
	item_title.add_theme_font_size_override("font_size", 18)
	item_box.add_child(item_title)

	var item_scroll: ScrollContainer = ScrollContainer.new()
	item_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_box.add_child(item_scroll)

	_item_list = VBoxContainer.new()
	_item_list.add_theme_constant_override("separation", 6)
	item_scroll.add_child(_item_list)

	var operation_panel: PanelContainer = PanelContainer.new()
	operation_panel.custom_minimum_size = Vector2(300, 0)
	operation_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(operation_panel)

	var op_margin: MarginContainer = _margin(10)
	operation_panel.add_child(op_margin)

	var op_box: VBoxContainer = VBoxContainer.new()
	op_box.add_theme_constant_override("separation", 8)
	op_margin.add_child(op_box)

	var op_title: Label = Label.new()
	op_title.text = "Operation"
	op_title.add_theme_font_size_override("font_size", 18)
	op_box.add_child(op_title)

	_operation_list = VBoxContainer.new()
	_operation_list.add_theme_constant_override("separation", 6)
	op_box.add_child(_operation_list)

	_notice_label = Label.new()
	_notice_label.text = ""
	_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	op_box.add_child(_notice_label)

	var preview_panel: PanelContainer = PanelContainer.new()
	preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(preview_panel)

	var preview_margin: MarginContainer = _margin(10)
	preview_panel.add_child(preview_margin)

	var preview_box: VBoxContainer = VBoxContainer.new()
	preview_box.add_theme_constant_override("separation", 8)
	preview_margin.add_child(preview_box)

	var current_title: Label = Label.new()
	current_title.text = "Current Item"
	current_title.add_theme_font_size_override("font_size", 18)
	preview_box.add_child(current_title)

	_current_card = RichTextLabel.new()
	_current_card.name = "ForgeCurrentItemCard094E"
	_current_card.bbcode_enabled = true
	_current_card.scroll_active = true
	_current_card.fit_content = false
	_current_card.custom_minimum_size = Vector2(0, 170)
	preview_box.add_child(_current_card)

	var preview_title: Label = Label.new()
	preview_title.text = "Preview"
	preview_title.add_theme_font_size_override("font_size", 18)
	preview_box.add_child(preview_title)

	_preview_card = RichTextLabel.new()
	_preview_card.name = "ForgePreviewCard094E"
	_preview_card.bbcode_enabled = true
	_preview_card.scroll_active = true
	_preview_card.fit_content = false
	_preview_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview_card.custom_minimum_size = Vector2(0, 170)
	preview_box.add_child(_preview_card)

	_cost_label = RichTextLabel.new()
	_cost_label.bbcode_enabled = true
	_cost_label.fit_content = true
	_cost_label.scroll_active = false
	_cost_label.custom_minimum_size = Vector2(0, 86)
	preview_box.add_child(_cost_label)

	var action_row: HBoxContainer = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	main.add_child(action_row)

	var apply_button: Button = _button("Apply Craft", Vector2(132, 36))
	apply_button.pressed.connect(_apply_selected_craft)
	action_row.add_child(apply_button)

	var preview_button: Button = _button("Refresh Preview", Vector2(132, 36))
	preview_button.pressed.connect(_force_refresh)
	action_row.add_child(preview_button)

	var clear_button: Button = _button("Clear", Vector2(90, 36))
	clear_button.pressed.connect(_clear_selection)
	action_row.add_child(clear_button)

	var close_bottom: Button = _button("Close", Vector2(90, 36))
	close_bottom.pressed.connect(_close_panel)
	action_row.add_child(close_bottom)


func _refresh(force: bool) -> void:
	if state_ref == null:
		return
	_ensure_ui()

	var sig: String = _signature()
	if not force and sig == _last_signature:
		return
	_last_signature = sig

	_clamp_selection()
	_refresh_currency()
	_refresh_item_list()
	_refresh_operations()
	_refresh_preview()


func _signature() -> String:
	return JSON.stringify([
		_state_get("backpack", []),
		_state_get("currency", {}),
		_state_get("gold", 0),
		selected_item_index,
		selected_operation,
	])


func _clamp_selection() -> void:
	var backpack: Array = Array(_state_get("backpack", []))
	if backpack.is_empty():
		selected_item_index = -1
	else:
		selected_item_index = clampi(selected_item_index, -1, backpack.size() - 1)


func _refresh_currency() -> void:
	var currency: Dictionary = Dictionary(_state_get("currency", {}))
	var gold: int = _to_int(_state_get("gold", 0), 0)
	var scrap: int = _to_int(currency.get("scrap", 0), 0)
	var shards: int = _to_int(currency.get("shard", currency.get("shards", 0)), 0)
	var crystals: int = _to_int(currency.get("crystal", currency.get("crystals", 0)), 0)
	_currency_label.text = "Gold " + str(gold) + " · Scrap " + str(scrap) + " · Shards " + str(shards) + " · Crystals " + str(crystals)


func _refresh_item_list() -> void:
	_clear_children(_item_list)

	var backpack: Array = Array(_state_get("backpack", []))
	var count: int = 0

	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i])
		if not _is_craftable(item):
			continue

		count += 1
		var button: Button = _button(_item_button_text(i, item), Vector2(0, 74))
		button.clip_text = true
		button.modulate = UIFoundationSystemScript.rarity_color(str(item.get("rarity", "normal")))
		if i == selected_item_index:
			button.text = "▶ " + button.text
		button.pressed.connect(_select_item.bind(i))
		_item_list.add_child(button)

	if count == 0:
		var label: Label = Label.new()
		label.text = "No craftable backpack items."
		_item_list.add_child(label)


func _refresh_operations() -> void:
	_clear_children(_operation_list)

	for op_id: String in OPERATION_ORDER:
		var button: Button = _button(_operation_button_text(op_id), Vector2(0, 78))
		button.clip_text = true
		if op_id == selected_operation:
			button.text = "▶ " + button.text
		button.pressed.connect(_select_operation.bind(op_id))
		_operation_list.add_child(button)


func _refresh_preview() -> void:
	var item: Dictionary = _selected_item()
	if item.is_empty():
		_current_card.text = "[i]Select a craftable item.[/i]"
		_preview_card.text = "[i]No preview.[/i]"
		_cost_label.text = ""
		return

	var preview: Dictionary = _preview_item(item, selected_operation)
	var cost: Dictionary = _operation_cost(selected_operation, item)

	_current_card.text = UIFoundationSystemScript.item_card_text(item, {})
	_preview_card.text = UIFoundationSystemScript.item_card_text(preview, item)
	_cost_label.text = _cost_text(cost, item, selected_operation)


func _select_item(index: int) -> void:
	selected_item_index = index
	_last_signature = ""
	_refresh(true)


func _select_operation(op_id: String) -> void:
	selected_operation = op_id
	_last_signature = ""
	_refresh(true)


func _clear_selection() -> void:
	selected_item_index = -1
	_last_signature = ""
	_refresh(true)


func _force_refresh() -> void:
	_last_signature = ""
	_refresh(true)


func _apply_selected_craft() -> void:
	if state_ref == null:
		return

	var backpack: Array = Array(_state_get("backpack", []))
	if selected_item_index < 0 or selected_item_index >= backpack.size() or typeof(backpack[selected_item_index]) != TYPE_DICTIONARY:
		_notice("Select a craftable item first.")
		return

	var item: Dictionary = Dictionary(backpack[selected_item_index])
	if not _is_craftable(item):
		_notice("That item cannot be crafted.")
		return

	var cost: Dictionary = _operation_cost(selected_operation, item)
	if not _can_pay(cost):
		_notice("Not enough currency.")
		return

	if selected_operation != OP_RESTORE_POTENTIAL and _forge_potential(item) <= 0:
		_notice("No forge potential left.")
		return

	_pay(cost)

	var result: Dictionary = item.duplicate(true)
	match selected_operation:
		OP_REFINE:
			result = _apply_refine(result)
			result["forge_potential"] = max(0, _forge_potential(result) - 1)
		OP_ADD_AFFIX:
			result = _apply_add_affix(result)
			result["forge_potential"] = max(0, _forge_potential(result) - 2)
		OP_UPGRADE_RARITY:
			result = _apply_upgrade_rarity(result)
			result["forge_potential"] = max(0, _forge_potential(result) - 3)
		OP_ADD_QUALITY:
			result = _apply_add_quality(result)
			result["forge_potential"] = max(0, _forge_potential(result) - 1)
		OP_RESTORE_POTENTIAL:
			result = _apply_restore_potential(result)
		_:
			_notice("Unknown operation.")
			return

	backpack[selected_item_index] = result
	state_ref.set("backpack", backpack)
	_notice("Craft applied: " + _operation_name(selected_operation) + ".")
	_last_signature = ""
	_refresh(true)


func _preview_item(item: Dictionary, op_id: String) -> Dictionary:
	var result: Dictionary = item.duplicate(true)
	match op_id:
		OP_REFINE:
			result = _apply_refine_preview(result)
			result["forge_potential"] = max(0, _forge_potential(result) - 1)
		OP_ADD_AFFIX:
			result = _apply_add_affix_preview(result)
			result["forge_potential"] = max(0, _forge_potential(result) - 2)
		OP_UPGRADE_RARITY:
			result["rarity"] = _next_rarity(str(result.get("rarity", "normal")))
			result["forge_potential"] = max(0, _forge_potential(result) - 3)
		OP_ADD_QUALITY:
			result["quality"] = min(20, _to_int(result.get("quality", 0), 0) + 2)
			result["forge_potential"] = max(0, _forge_potential(result) - 1)
		OP_RESTORE_POTENTIAL:
			result["forge_potential"] = _forge_potential(result) + 3
		_:
			pass
	return result


func _apply_refine(item: Dictionary) -> Dictionary:
	return _apply_refine_preview(item)


func _apply_refine_preview(item: Dictionary) -> Dictionary:
	var stats: Dictionary = Dictionary(item.get("total_stats", item.get("stats", {})))
	if stats.is_empty():
		stats["damage"] = 1
	else:
		for key: Variant in stats.keys():
			var current: int = _to_int(stats[key], 0)
			stats[key] = current + max(1, int(ceil(float(abs(current)) * 0.05)))
	item["stats"] = stats
	item["total_stats"] = stats
	return item


func _apply_add_affix(item: Dictionary) -> Dictionary:
	return _apply_add_affix_preview(item)


func _apply_add_affix_preview(item: Dictionary) -> Dictionary:
	var affixes: Array = Array(item.get("affixes", []))
	var stat_id: String = _legal_affix_for_item(item, affixes.size())
	var value: int = _affix_value(stat_id)
	affixes.append({"stat": stat_id, "value": value})
	item["affixes"] = affixes

	var stats: Dictionary = Dictionary(item.get("total_stats", item.get("stats", {})))
	stats[stat_id] = _to_int(stats.get(stat_id, 0), 0) + value
	item["stats"] = stats
	item["total_stats"] = stats

	if str(item.get("rarity", "normal")).to_lower() == "normal":
		item["rarity"] = "magic"
	elif str(item.get("rarity", "normal")).to_lower() == "magic" and affixes.size() >= 3:
		item["rarity"] = "rare"

	return item


func _apply_upgrade_rarity(item: Dictionary) -> Dictionary:
	item["rarity"] = _next_rarity(str(item.get("rarity", "normal")))
	return item


func _apply_add_quality(item: Dictionary) -> Dictionary:
	item["quality"] = min(20, _to_int(item.get("quality", 0), 0) + 2)
	return item


func _apply_restore_potential(item: Dictionary) -> Dictionary:
	var roll: float = randf()
	var current: int = _forge_potential(item)
	if roll < 0.50:
		item["forge_potential"] = current + 4
		_notice("Risk succeeded: potential restored.")
	elif roll < 0.85:
		item["forge_potential"] = current
		_notice("Risk failed: no potential restored.")
	else:
		item["forge_potential"] = max(0, current - 2)
		item["fractured"] = true
		_notice("Risk backfired: item fractured.")
	return item


func _operation_cost(op_id: String, item: Dictionary) -> Dictionary:
	var item_level: int = max(1, _to_int(item.get("item_level", item.get("level", 1)), 1))
	match op_id:
		OP_REFINE:
			return {"gold": 25 + item_level * 2, "scrap": 1, "shards": 0, "crystals": 0}
		OP_ADD_AFFIX:
			return {"gold": 45 + item_level * 3, "scrap": 2, "shards": 1, "crystals": 0}
		OP_UPGRADE_RARITY:
			return {"gold": 90 + item_level * 4, "scrap": 0, "shards": 3, "crystals": 0}
		OP_ADD_QUALITY:
			return {"gold": 60 + item_level * 3, "scrap": 0, "shards": 0, "crystals": 1}
		OP_RESTORE_POTENTIAL:
			return {"gold": 180 + item_level * 5, "scrap": 0, "shards": 0, "crystals": 3}
		_:
			return {"gold": 0, "scrap": 0, "shards": 0, "crystals": 0}


func _cost_text(cost: Dictionary, item: Dictionary, op_id: String) -> String:
	var lines: PackedStringArray = []
	lines.append("[b]Operation[/b]: " + _operation_name(op_id))
	lines.append("[b]Cost[/b]: Gold " + str(_to_int(cost.get("gold", 0), 0)) + " · Scrap " + str(_to_int(cost.get("scrap", 0), 0)) + " · Shards " + str(_to_int(cost.get("shards", 0), 0)) + " · Crystals " + str(_to_int(cost.get("crystals", 0), 0)))
	lines.append("[b]Forge Potential[/b]: " + str(_forge_potential(item)) + " → " + str(_to_int(_preview_item(item, op_id).get("forge_potential", _forge_potential(item)), _forge_potential(item))))
	lines.append("[b]Risk[/b]: " + _operation_risk(op_id))
	if not _can_pay(cost):
		lines.append("[color=red]You cannot afford this operation.[/color]")
	elif op_id != OP_RESTORE_POTENTIAL and _forge_potential(item) <= 0:
		lines.append("[color=red]This item has no forge potential left.[/color]")
	else:
		lines.append("[color=green]Ready to craft.[/color]")
	return "\n".join(lines)


func _can_pay(cost: Dictionary) -> bool:
	var currency: Dictionary = Dictionary(_state_get("currency", {}))
	var gold: int = _to_int(_state_get("gold", 0), 0)
	var scrap: int = _to_int(currency.get("scrap", 0), 0)
	var shards: int = _to_int(currency.get("shard", currency.get("shards", 0)), 0)
	var crystals: int = _to_int(currency.get("crystal", currency.get("crystals", 0)), 0)

	return gold >= _to_int(cost.get("gold", 0), 0) and scrap >= _to_int(cost.get("scrap", 0), 0) and shards >= _to_int(cost.get("shards", 0), 0) and crystals >= _to_int(cost.get("crystals", 0), 0)


func _pay(cost: Dictionary) -> void:
	var currency: Dictionary = Dictionary(_state_get("currency", {}))
	var gold: int = _to_int(_state_get("gold", 0), 0)
	state_ref.set("gold", max(0, gold - _to_int(cost.get("gold", 0), 0)))

	currency["scrap"] = max(0, _to_int(currency.get("scrap", 0), 0) - _to_int(cost.get("scrap", 0), 0))
	currency["shard"] = max(0, _to_int(currency.get("shard", currency.get("shards", 0)), 0) - _to_int(cost.get("shards", 0), 0))
	currency["shards"] = currency["shard"]
	currency["crystal"] = max(0, _to_int(currency.get("crystal", currency.get("crystals", 0)), 0) - _to_int(cost.get("crystals", 0), 0))
	currency["crystals"] = currency["crystal"]
	state_ref.set("currency", currency)


func _legal_affix_for_item(item: Dictionary, offset: int) -> String:
	var slot: String = str(item.get("slot", "")).strip_edges().to_lower()
	var weapon_affixes: Array[String] = ["damage", "attack_speed", "crit_chance"]
	var armor_affixes: Array[String] = ["max_health", "armor", "fire_resistance", "cold_resistance", "lightning_resistance"]
	var jewelry_affixes: Array[String] = ["max_mana", "spell_damage", "cast_speed", "crit_chance"]
	var offhand_affixes: Array[String] = ["block_chance", "spell_damage", "max_mana"]

	if slot == "weapon":
		return weapon_affixes[offset % weapon_affixes.size()]
	if slot in ["helm", "head", "chest", "gloves", "boots"]:
		return armor_affixes[offset % armor_affixes.size()]
	if slot in ["amulet", "ring", "ring1", "ring2", "relic"]:
		return jewelry_affixes[offset % jewelry_affixes.size()]
	if slot in ["offhand", "shield"]:
		return offhand_affixes[offset % offhand_affixes.size()]
	return armor_affixes[offset % armor_affixes.size()]


func _affix_value(stat_id: String) -> int:
	match stat_id:
		"damage":
			return 4
		"attack_speed":
			return 3
		"cast_speed":
			return 3
		"crit_chance":
			return 3
		"spell_damage":
			return 5
		"max_health":
			return 18
		"max_mana":
			return 12
		"armor":
			return 10
		"block_chance":
			return 4
		"fire_resistance", "cold_resistance", "lightning_resistance":
			return 8
		_:
			return 5


func _selected_item() -> Dictionary:
	var backpack: Array = Array(_state_get("backpack", []))
	if selected_item_index < 0 or selected_item_index >= backpack.size() or typeof(backpack[selected_item_index]) != TYPE_DICTIONARY:
		return {}
	return Dictionary(backpack[selected_item_index])


func _is_craftable(item: Dictionary) -> bool:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).strip_edges().to_lower()
	var slot: String = str(item.get("slot", "")).strip_edges().to_lower()
	if kind in ["currency", "map", "map_item", "crystal", "active_gem", "support_gem", "spirit_gem", "skill_gem"]:
		return false
	if slot in ["active_gem", "support_gem", "spirit_gem", "map"]:
		return false
	return true


func _item_button_text(index: int, item: Dictionary) -> String:
	var name: String = _short(str(item.get("display_name", item.get("name", "Item"))), 24)
	var rarity: String = str(item.get("rarity", "normal")).capitalize()
	var slot: String = str(item.get("slot", item.get("kind", "item"))).capitalize()
	var potential: int = _forge_potential(item)
	return "#" + str(index + 1) + " · " + rarity + "\n" + name + "\n" + slot + " · FP " + str(potential)


func _operation_button_text(op_id: String) -> String:
	return _operation_name(op_id) + "\n" + _operation_description(op_id)


func _operation_name(op_id: String) -> String:
	match op_id:
		OP_REFINE:
			return "Refine Values"
		OP_ADD_AFFIX:
			return "Add Random Affix"
		OP_UPGRADE_RARITY:
			return "Upgrade Rarity"
		OP_ADD_QUALITY:
			return "Add Quality"
		OP_RESTORE_POTENTIAL:
			return "Risky Restore Potential"
		_:
			return "Unknown"


func _operation_description(op_id: String) -> String:
	match op_id:
		OP_REFINE:
			return "Improve numeric stats. -1 FP."
		OP_ADD_AFFIX:
			return "Add a legal stat affix. -2 FP."
		OP_UPGRADE_RARITY:
			return "Normal → Magic → Rare. -3 FP."
		OP_ADD_QUALITY:
			return "Increase item quality. -1 FP."
		OP_RESTORE_POTENTIAL:
			return "Can restore, fail, or fracture."
		_:
			return ""


func _operation_risk(op_id: String) -> String:
	match op_id:
		OP_RESTORE_POTENTIAL:
			return "High. 50% restore, 35% fail, 15% fracture."
		_:
			return "None. Deterministic if you can pay and have potential."


func _next_rarity(value: String) -> String:
	match value.strip_edges().to_lower():
		"normal":
			return "magic"
		"magic":
			return "rare"
		"rare":
			return "rare"
		"unique":
			return "unique"
		_:
			return "magic"


func _forge_potential(item: Dictionary) -> int:
	if item.has("forge_potential"):
		return _to_int(item.get("forge_potential", 0), 0)
	var rarity: String = str(item.get("rarity", "normal")).to_lower()
	match rarity:
		"normal":
			return 8
		"magic":
			return 6
		"rare":
			return 4
		"unique":
			return 2
		_:
			return 5


func _button(text_value: String, min_size: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = min_size
	button.clip_text = true
	return button


func _margin(size: int) -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", size)
	margin.add_theme_constant_override("margin_top", size)
	margin.add_theme_constant_override("margin_right", size)
	margin.add_theme_constant_override("margin_bottom", size)
	return margin


func _close_panel() -> void:
	if state_ref != null:
		state_ref.set("panel_mode", "")


func _notice(value: String) -> void:
	if _notice_label != null:
		_notice_label.text = value
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", value)


func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value


func _clear_children(node: Node) -> void:
	if node == null:
		return
	for child: Node in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _short(value: String, limit: int) -> String:
	if value.length() <= limit:
		return value
	return value.substr(0, max(1, limit - 1)) + "…"


func _to_int(value: Variant, fallback: int = 0) -> int:
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
