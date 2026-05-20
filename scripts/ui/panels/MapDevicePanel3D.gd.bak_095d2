extends Control

const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")

const FILTER_RARITY_ALL: int = 0
const FILTER_RARITY_NORMAL: int = 1
const FILTER_RARITY_MAGIC: int = 2
const FILTER_RARITY_RARE: int = 3

const FILTER_SOURCE_ALL: int = 0
const FILTER_SOURCE_BACKPACK: int = 1
const FILTER_SOURCE_STASH: int = 2

var state_ref: Object = null
var selected_map_view_index: int = -1
var rarity_filter: int = FILTER_RARITY_ALL
var source_filter: int = FILTER_SOURCE_ALL
var min_tier_filter: int = 1
var max_tier_filter: int = 15
var _last_signature: String = ""

var _root: PanelContainer = null
var _map_list: VBoxContainer = null
var _selected_card: RichTextLabel = null
var _objective_card: RichTextLabel = null
var _atlas_card: RichTextLabel = null
var _notice_label: Label = null
var _rarity_filter: OptionButton = null
var _source_filter: OptionButton = null
var _min_tier_spin: SpinBox = null
var _max_tier_spin: SpinBox = null
var _available_maps: Array = []


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
	_root.name = "MapDeviceRoot094F"
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
	title.text = "Map Device"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_button: Button = _button("Close", Vector2(86, 34))
	close_button.pressed.connect(_close_panel)
	header.add_child(close_button)

	var hint: RichTextLabel = RichTextLabel.new()
	hint.bbcode_enabled = true
	hint.fit_content = true
	hint.scroll_active = false
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.custom_minimum_size = Vector2(0, 44)
	hint.text = "[b]Map Device[/b] · Choose a physical map item, inspect tier/rarity/objectives, then open the run. Bonus rules change by tier band."
	main.add_child(hint)

	var filter_row: HBoxContainer = HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 8)
	main.add_child(filter_row)

	_rarity_filter = OptionButton.new()
	_rarity_filter.add_item("All Rarities", FILTER_RARITY_ALL)
	_rarity_filter.add_item("Normal", FILTER_RARITY_NORMAL)
	_rarity_filter.add_item("Magic", FILTER_RARITY_MAGIC)
	_rarity_filter.add_item("Rare", FILTER_RARITY_RARE)
	_rarity_filter.item_selected.connect(_on_rarity_filter)
	filter_row.add_child(_rarity_filter)

	_source_filter = OptionButton.new()
	_source_filter.add_item("All Sources", FILTER_SOURCE_ALL)
	_source_filter.add_item("Backpack", FILTER_SOURCE_BACKPACK)
	_source_filter.add_item("Stash", FILTER_SOURCE_STASH)
	_source_filter.item_selected.connect(_on_source_filter)
	filter_row.add_child(_source_filter)

	var min_label: Label = Label.new()
	min_label.text = "Tier"
	filter_row.add_child(min_label)

	_min_tier_spin = SpinBox.new()
	_min_tier_spin.min_value = 1
	_min_tier_spin.max_value = 15
	_min_tier_spin.step = 1
	_min_tier_spin.value = 1
	_min_tier_spin.custom_minimum_size = Vector2(72, 32)
	_min_tier_spin.value_changed.connect(_on_min_tier_changed)
	filter_row.add_child(_min_tier_spin)

	var to_label: Label = Label.new()
	to_label.text = "to"
	filter_row.add_child(to_label)

	_max_tier_spin = SpinBox.new()
	_max_tier_spin.min_value = 1
	_max_tier_spin.max_value = 15
	_max_tier_spin.step = 1
	_max_tier_spin.value = 15
	_max_tier_spin.custom_minimum_size = Vector2(72, 32)
	_max_tier_spin.value_changed.connect(_on_max_tier_changed)
	filter_row.add_child(_max_tier_spin)

	var refresh_button: Button = _button("Refresh", Vector2(96, 32))
	refresh_button.pressed.connect(_force_refresh)
	filter_row.add_child(refresh_button)

	var body: HBoxContainer = HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(body)

	var list_panel: PanelContainer = PanelContainer.new()
	list_panel.custom_minimum_size = Vector2(330, 0)
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(list_panel)

	var list_margin: MarginContainer = _margin(10)
	list_panel.add_child(list_margin)

	var list_box: VBoxContainer = VBoxContainer.new()
	list_box.add_theme_constant_override("separation", 8)
	list_margin.add_child(list_box)

	var list_title: Label = Label.new()
	list_title.text = "Available Maps"
	list_title.add_theme_font_size_override("font_size", 18)
	list_box.add_child(list_title)

	var list_scroll: ScrollContainer = ScrollContainer.new()
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_box.add_child(list_scroll)

	_map_list = VBoxContainer.new()
	_map_list.add_theme_constant_override("separation", 6)
	list_scroll.add_child(_map_list)

	var preview_panel: PanelContainer = PanelContainer.new()
	preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(preview_panel)

	var preview_margin: MarginContainer = _margin(10)
	preview_panel.add_child(preview_margin)

	var preview_box: VBoxContainer = VBoxContainer.new()
	preview_box.add_theme_constant_override("separation", 8)
	preview_margin.add_child(preview_box)

	var selected_title: Label = Label.new()
	selected_title.text = "Selected Map"
	selected_title.add_theme_font_size_override("font_size", 18)
	preview_box.add_child(selected_title)

	_selected_card = RichTextLabel.new()
	_selected_card.name = "SelectedMapCard094F"
	_selected_card.bbcode_enabled = true
	_selected_card.scroll_active = true
	_selected_card.fit_content = false
	_selected_card.custom_minimum_size = Vector2(0, 210)
	preview_box.add_child(_selected_card)

	var objective_title: Label = Label.new()
	objective_title.text = "Objective / Bonus"
	objective_title.add_theme_font_size_override("font_size", 18)
	preview_box.add_child(objective_title)

	_objective_card = RichTextLabel.new()
	_objective_card.name = "MapObjectiveCard094F"
	_objective_card.bbcode_enabled = true
	_objective_card.scroll_active = true
	_objective_card.fit_content = false
	_objective_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_objective_card.custom_minimum_size = Vector2(0, 180)
	preview_box.add_child(_objective_card)

	var atlas_panel: PanelContainer = PanelContainer.new()
	atlas_panel.custom_minimum_size = Vector2(330, 0)
	atlas_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(atlas_panel)

	var atlas_margin: MarginContainer = _margin(10)
	atlas_panel.add_child(atlas_margin)

	var atlas_box: VBoxContainer = VBoxContainer.new()
	atlas_box.add_theme_constant_override("separation", 8)
	atlas_margin.add_child(atlas_box)

	var atlas_title: Label = Label.new()
	atlas_title.text = "Atlas Progress"
	atlas_title.add_theme_font_size_override("font_size", 18)
	atlas_box.add_child(atlas_title)

	_atlas_card = RichTextLabel.new()
	_atlas_card.name = "AtlasProgressCard094F"
	_atlas_card.bbcode_enabled = true
	_atlas_card.scroll_active = true
	_atlas_card.fit_content = false
	_atlas_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	atlas_box.add_child(_atlas_card)

	_notice_label = Label.new()
	_notice_label.text = ""
	_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.add_child(_notice_label)

	var action_row: HBoxContainer = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	main.add_child(action_row)

	var open_button: Button = _button("Open Map", Vector2(132, 36))
	open_button.pressed.connect(_open_selected_map)
	action_row.add_child(open_button)

	var clear_button: Button = _button("Clear Selection", Vector2(132, 36))
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

	_sync_filter_controls()
	_collect_available_maps()
	_clamp_selection()
	_refresh_map_list()
	_refresh_selected()
	_refresh_atlas()


func _signature() -> String:
	return JSON.stringify([
		_state_get("backpack", []),
		_state_get("stash_tabs", []),
		_state_get("map_completion", {}),
		selected_map_view_index,
		rarity_filter,
		source_filter,
		min_tier_filter,
		max_tier_filter,
	])


func _sync_filter_controls() -> void:
	if _rarity_filter != null and _rarity_filter.selected != rarity_filter:
		_rarity_filter.select(rarity_filter)
	if _source_filter != null and _source_filter.selected != source_filter:
		_source_filter.select(source_filter)
	if _min_tier_spin != null and int(_min_tier_spin.value) != min_tier_filter:
		_min_tier_spin.value = min_tier_filter
	if _max_tier_spin != null and int(_max_tier_spin.value) != max_tier_filter:
		_max_tier_spin.value = max_tier_filter


func _collect_available_maps() -> void:
	_available_maps.clear()

	var backpack: Array = Array(_state_get("backpack", []))
	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i]).duplicate(true)
		if not _is_map_item(item):
			continue
		item["_map_source"] = "backpack"
		item["_map_source_label"] = "Backpack"
		item["_map_item_index"] = i
		_maybe_add_filtered_map(item)

	var stash_tabs: Array = Array(_state_get("stash_tabs", []))
	for tab_index: int in range(stash_tabs.size()):
		if typeof(stash_tabs[tab_index]) != TYPE_DICTIONARY:
			continue
		var tab: Dictionary = Dictionary(stash_tabs[tab_index])
		var affinity: String = str(tab.get("affinity", "")).to_lower()
		var items: Array = Array(tab.get("items", []))
		for item_index: int in range(items.size()):
			if typeof(items[item_index]) != TYPE_DICTIONARY:
				continue
			var stash_item: Dictionary = Dictionary(items[item_index]).duplicate(true)
			if not _is_map_item(stash_item) and affinity != "maps":
				continue
			if not _is_map_item(stash_item):
				continue
			stash_item["_map_source"] = "stash"
			stash_item["_map_source_label"] = "Stash · " + str(tab.get("name", "Maps"))
			stash_item["_map_tab_index"] = tab_index
			stash_item["_map_tab_id"] = str(tab.get("id", ""))
			stash_item["_map_item_index"] = item_index
			_maybe_add_filtered_map(stash_item)

	_available_maps.sort_custom(_map_sort_less)


func _maybe_add_filtered_map(item: Dictionary) -> void:
	var tier: int = _map_tier(item)
	var rarity: String = _map_rarity(item)
	var source: String = str(item.get("_map_source", ""))

	if tier < min_tier_filter or tier > max_tier_filter:
		return

	match rarity_filter:
		FILTER_RARITY_NORMAL:
			if rarity != "normal":
				return
		FILTER_RARITY_MAGIC:
			if rarity != "magic":
				return
		FILTER_RARITY_RARE:
			if rarity != "rare":
				return

	match source_filter:
		FILTER_SOURCE_BACKPACK:
			if source != "backpack":
				return
		FILTER_SOURCE_STASH:
			if source != "stash":
				return

	_available_maps.append(item)


func _map_sort_less(a: Dictionary, b: Dictionary) -> bool:
	var ta: int = _map_tier(a)
	var tb: int = _map_tier(b)
	if ta != tb:
		return ta < tb

	var ra: int = _rarity_rank(_map_rarity(a))
	var rb: int = _rarity_rank(_map_rarity(b))
	if ra != rb:
		return ra < rb

	var na: String = str(a.get("display_name", a.get("name", "")))
	var nb: String = str(b.get("display_name", b.get("name", "")))
	return na < nb


func _clamp_selection() -> void:
	if _available_maps.is_empty():
		selected_map_view_index = -1
	else:
		selected_map_view_index = clampi(selected_map_view_index, -1, _available_maps.size() - 1)


func _refresh_map_list() -> void:
	_clear_children(_map_list)

	if _available_maps.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No map items match the filters."
		_map_list.add_child(empty_label)
		return

	var current_band: String = ""
	for i: int in range(_available_maps.size()):
		var item: Dictionary = Dictionary(_available_maps[i])
		var band: String = _tier_band_label(_map_tier(item))
		if band != current_band:
			current_band = band
			var band_label: Label = Label.new()
			band_label.text = band
			band_label.add_theme_font_size_override("font_size", 16)
			_map_list.add_child(band_label)

		var button: Button = _button(_map_button_text(i, item), Vector2(0, 78))
		button.clip_text = true
		button.modulate = UIFoundationSystemScript.rarity_color(_map_rarity(item))
		if i == selected_map_view_index:
			button.text = "▶ " + button.text
		button.pressed.connect(_select_map.bind(i))
		button.gui_input.connect(_on_map_gui_input.bind(i))
		_map_list.add_child(button)


func _map_button_text(index: int, item: Dictionary) -> String:
	var tier: int = _map_tier(item)
	var rarity: String = _map_rarity(item).capitalize()
	var name: String = _short(str(item.get("display_name", item.get("name", "Map"))), 24)
	var source: String = str(item.get("_map_source_label", ""))
	var completion: Dictionary = _completion_for_map(item)
	var flags: String = ""
	if bool(completion.get("completed", false)):
		flags += "✓"
	if bool(completion.get("bonus", false)):
		flags += "★"
	return "T" + str(tier) + " · " + rarity + " " + flags + "\n" + name + "\n" + source


func _refresh_selected() -> void:
	var item: Dictionary = _selected_map()
	if item.is_empty():
		_selected_card.text = "[i]Select a map item.[/i]"
		_objective_card.text = "[i]No map selected.[/i]"
		return

	_selected_card.text = UIFoundationSystemScript.item_card_text(item, {})
	_objective_card.text = _objective_text(item)


func _objective_text(item: Dictionary) -> String:
	var tier: int = _map_tier(item)
	var rarity: String = _map_rarity(item)
	var completion: Dictionary = _completion_for_map(item)
	var lines: PackedStringArray = []

	lines.append("[b]Tier " + str(tier) + " " + rarity.capitalize() + " Map[/b]")
	lines.append("Source: " + str(item.get("_map_source_label", "Unknown")))
	lines.append("Completion: " + ("Complete" if bool(completion.get("completed", false)) else "Incomplete"))
	lines.append("Bonus: " + ("Complete" if bool(completion.get("bonus", false)) else "Incomplete"))
	lines.append("")
	lines.append("[b]Rules[/b]")
	lines.append("Completion: clear the map.")
	lines.append("Bonus: " + _bonus_requirement_text(tier))
	lines.append("")
	lines.append("[b]This Map[/b]")
	if _map_meets_bonus_requirement(item):
		lines.append("[color=green]This map can satisfy its bonus objective if cleared.[/color]")
	else:
		lines.append("[color=red]This map cannot satisfy its bonus objective until upgraded to the required rarity.[/color]")

	var mods: Array = Array(item.get("mods", item.get("map_mods", [])))
	if not mods.is_empty():
		lines.append("")
		lines.append("[b]Map Mods[/b]")
		for mod_value: Variant in mods:
			lines.append("• " + str(mod_value))

	return "\n".join(lines)


func _refresh_atlas() -> void:
	var completion: Dictionary = Dictionary(_state_get("map_completion", {}))
	var lines: PackedStringArray = []
	lines.append("[b]Atlas Summary[/b]")
	lines.append("Tracked maps: " + str(completion.size()))
	lines.append("")

	lines.append(_band_progress_text("Tier 1–5", 1, 5))
	lines.append("")
	lines.append(_band_progress_text("Tier 6–9", 6, 9))
	lines.append("")
	lines.append(_band_progress_text("Tier 10–15", 10, 15))
	lines.append("")
	lines.append("[b]Bonus Rules[/b]")
	lines.append("T1–5: clear the map.")
	lines.append("T6–9: clear as Magic or Rare.")
	lines.append("T10–15: clear as Rare.")

	_atlas_card.text = "\n".join(lines)


func _band_progress_text(label: String, min_tier: int, max_tier: int) -> String:
	var completion: Dictionary = Dictionary(_state_get("map_completion", {}))
	var completed: int = 0
	var bonus: int = 0
	var seen: int = 0

	for key: Variant in completion.keys():
		var data: Variant = completion[key]
		if typeof(data) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = Dictionary(data)
		var tier: int = _to_int(d.get("tier", 0), 0)
		if tier < min_tier or tier > max_tier:
			continue
		seen += 1
		if bool(d.get("completed", false)):
			completed += 1
		if bool(d.get("bonus", false)):
			bonus += 1

	return "[b]" + label + "[/b]\nSeen: " + str(seen) + " · Completed: " + str(completed) + " · Bonus: " + str(bonus)


func _select_map(index: int) -> void:
	selected_map_view_index = index
	_last_signature = ""
	_refresh(true)


func _on_map_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.double_click:
			_select_map(index)
			_open_selected_map()


func _open_selected_map() -> void:
	if state_ref == null:
		return

	var item: Dictionary = _selected_map()
	if item.is_empty():
		_notice("Select a map first.")
		return

	var active_map: Dictionary = item.duplicate(true)
	active_map.erase("_map_source")
	active_map.erase("_map_source_label")
	active_map.erase("_map_item_index")
	active_map.erase("_map_tab_index")
	active_map.erase("_map_tab_id")

	state_ref.set("active_map_item", active_map)
	state_ref.set("active_map_tier", _map_tier(active_map))
	state_ref.set("active_map_rarity", _map_rarity(active_map))
	state_ref.set("active_map_name", str(active_map.get("display_name", active_map.get("name", "Map"))))

	_consume_selected_map_item(item)

	state_ref.set("panel_mode", "")
	_notice("Opening " + str(active_map.get("display_name", active_map.get("name", "map"))) + ".")

	var scene: Node = get_tree().current_scene
	if scene != null:
		if scene.has_method("_start_map"):
			scene.call("_start_map")
			return
		if scene.has_method("start_map"):
			scene.call("start_map")
			return
		if scene.has_method("_open_selected_map"):
			scene.call("_open_selected_map")
			return

	state_ref.set("mode", "combat")


func _consume_selected_map_item(item: Dictionary) -> void:
	var source: String = str(item.get("_map_source", ""))
	var index: int = _to_int(item.get("_map_item_index", -1), -1)

	if source == "backpack":
		var backpack: Array = Array(_state_get("backpack", []))
		if index >= 0 and index < backpack.size():
			backpack.remove_at(index)
			state_ref.set("backpack", backpack)
		return

	if source == "stash":
		var tab_index: int = _to_int(item.get("_map_tab_index", -1), -1)
		var stash_tabs: Array = Array(_state_get("stash_tabs", []))
		if tab_index < 0 or tab_index >= stash_tabs.size() or typeof(stash_tabs[tab_index]) != TYPE_DICTIONARY:
			return
		var tab: Dictionary = Dictionary(stash_tabs[tab_index])
		var items: Array = Array(tab.get("items", []))
		if index >= 0 and index < items.size():
			items.remove_at(index)
			tab["items"] = items
			stash_tabs[tab_index] = tab
			state_ref.set("stash_tabs", stash_tabs)


func _clear_selection() -> void:
	selected_map_view_index = -1
	_last_signature = ""
	_refresh(true)


func _force_refresh() -> void:
	_last_signature = ""
	_refresh(true)


func _on_rarity_filter(index: int) -> void:
	rarity_filter = index
	selected_map_view_index = -1
	_last_signature = ""
	_refresh(true)


func _on_source_filter(index: int) -> void:
	source_filter = index
	selected_map_view_index = -1
	_last_signature = ""
	_refresh(true)


func _on_min_tier_changed(value: float) -> void:
	min_tier_filter = clampi(int(value), 1, 15)
	if min_tier_filter > max_tier_filter:
		max_tier_filter = min_tier_filter
	selected_map_view_index = -1
	_last_signature = ""
	_refresh(true)


func _on_max_tier_changed(value: float) -> void:
	max_tier_filter = clampi(int(value), 1, 15)
	if max_tier_filter < min_tier_filter:
		min_tier_filter = max_tier_filter
	selected_map_view_index = -1
	_last_signature = ""
	_refresh(true)


func _selected_map() -> Dictionary:
	if selected_map_view_index < 0 or selected_map_view_index >= _available_maps.size():
		return {}
	if typeof(_available_maps[selected_map_view_index]) != TYPE_DICTIONARY:
		return {}
	return Dictionary(_available_maps[selected_map_view_index])


func _is_map_item(item: Dictionary) -> bool:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).strip_edges().to_lower()
	var slot: String = str(item.get("slot", "")).strip_edges().to_lower()
	var tags: Array = Array(item.get("tags", []))
	if kind == "map" or kind == "map_item" or slot == "map":
		return true
	for tag_value: Variant in tags:
		if str(tag_value).to_lower() == "map":
			return true
	return item.has("map_tier") or item.has("tier")


func _map_tier(item: Dictionary) -> int:
	return clampi(_to_int(item.get("tier", item.get("map_tier", 1)), 1), 1, 15)


func _map_rarity(item: Dictionary) -> String:
	var rarity: String = str(item.get("rarity", "normal")).strip_edges().to_lower()
	if rarity == "magic" or rarity == "rare":
		return rarity
	return "normal"


func _completion_key(item: Dictionary) -> String:
	var base: String = str(item.get("base_id", item.get("id", item.get("name", "map"))))
	return base + "_t" + str(_map_tier(item))


func _completion_for_map(item: Dictionary) -> Dictionary:
	var completion: Dictionary = Dictionary(_state_get("map_completion", {}))
	var key: String = _completion_key(item)
	if completion.has(key) and typeof(completion[key]) == TYPE_DICTIONARY:
		return Dictionary(completion[key])
	return {
		"tier": _map_tier(item),
		"completed": false,
		"bonus": false,
	}


func _bonus_requirement_text(tier: int) -> String:
	if tier <= 5:
		return "clear the map."
	if tier <= 9:
		return "complete the map as Magic or Rare."
	return "complete the map as Rare."


func _map_meets_bonus_requirement(item: Dictionary) -> bool:
	var tier: int = _map_tier(item)
	var rarity: String = _map_rarity(item)
	if tier <= 5:
		return true
	if tier <= 9:
		return rarity == "magic" or rarity == "rare"
	return rarity == "rare"


func _tier_band_label(tier: int) -> String:
	if tier <= 5:
		return "Tier 1–5 · White Maps"
	if tier <= 9:
		return "Tier 6–9 · Magic Bonus"
	return "Tier 10–15 · Rare Bonus"


func _rarity_rank(rarity: String) -> int:
	match rarity:
		"normal":
			return 0
		"magic":
			return 1
		"rare":
			return 2
		_:
			return 3


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
